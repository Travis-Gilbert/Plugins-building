#!/usr/bin/env bash
# PostToolUse hook: lint only files touched by an edit operation.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

theorem_require_jq || { printf '{"continue":true}\n'; exit 0; }

input=$(theorem_read_stdin)
repo_root=$(theorem_repo_root "$input")
cwd=$(theorem_resolve_cwd "$input")
if ! repo_root=$(cd "$repo_root" 2>/dev/null && pwd -P); then
  printf '{"continue":true}\n'
  exit 0
fi
if ! cwd=$(cd "$cwd" 2>/dev/null && pwd -P); then
  cwd="$repo_root"
fi
sid=$(theorem_session_id "$input")
session_key=$(theorem_session_key "$sid")
state_dir="$repo_root/.theorem/lint/$session_key"
touch_dir="$state_dir/touches"
pretool_dir="$state_dir/pretool"
mkdir -p "$touch_dir"

tool_name=$(printf '%s' "$input" | jq -r '
  if (.tool | type) == "object" then (.tool.name // "")
  elif (.tool | type) == "string" then .tool
  else (.tool_name // .name // "")
  end
' 2>/dev/null || printf '')

direct_paths=$(printf '%s' "$input" | jq -r '
  [
    .tool_input.file_path?,
    .tool_input.notebook_path?,
    .tool_input.path?,
    .path?,
    .payload.path?
  ]
  | map(select(type == "string" and length > 0))
  | .[]
' 2>/dev/null || printf '')
patch_text=$(printf '%s' "$input" | jq -r '
  .tool_input.patch?
  // .tool_input.input?
  // (if (.tool_input? | type) == "string" then .tool_input else empty end)
  // .input?
  // empty
' 2>/dev/null || printf '')
patch_paths=$(printf '%s\n' "$patch_text" \
  | sed -nE \
      -e 's/^\*\*\* (Add|Update|Delete) File: (.+)$/\2/p' \
      -e 's/^\*\*\* Move to: (.+)$/\1/p')

shell_paths=''
committed_paths=''
tool_use_id=$(theorem_jq "$input" '.tool_use_id')
case "$tool_name" in
  Bash|exec_command|functions.exec_command)
    shell_paths=$(
      {
        git -C "$repo_root" diff --name-only --no-renames -z
        git -C "$repo_root" diff --cached --name-only --no-renames -z
        git -C "$repo_root" ls-files --others --exclude-standard -z
      } 2>/dev/null \
        | tr '\0' '\n' \
        | awk 'NF && $0 !~ /^\.theorem(\/|$)/'
    )
    if [ -n "$tool_use_id" ]; then
      pretool_key=$(printf '%s' "$tool_use_id" | shasum -a 256 | awk '{print $1}')
      pretool_file="$pretool_dir/$pretool_key.json"
      if [ -s "$pretool_file" ]; then
        head_before=$(jq -r '.head_before // empty' "$pretool_file")
        head_after=$(git -C "$repo_root" rev-parse --verify HEAD 2>/dev/null || printf '')
        if [ -n "$head_before" ] \
          && [ -n "$head_after" ] \
          && [ "$head_before" != "$head_after" ] \
          && git -C "$repo_root" rev-parse --verify "${head_before}^{commit}" >/dev/null 2>&1; then
          committed_paths=$(git -C "$repo_root" diff --name-only --no-renames -z "$head_before" "$head_after" 2>/dev/null \
            | tr '\0' '\n' || printf '')
        fi
      fi
    fi
    ;;
esac

canonicalize_candidate() {
  local raw="$1"
  local base="$2"
  local candidate probe parent leaf suffix resolved

  [ -n "$raw" ] || return 0
  case "/$raw/" in
    *"/../"*) return 0 ;;
  esac
  case "$raw" in
    /*) candidate="$raw" ;;
    *) candidate="$base/$raw" ;;
  esac

  probe=${candidate%/}
  suffix=''
  while [ ! -e "$probe" ] && [ ! -L "$probe" ]; do
    leaf=${probe##*/}
    [ -n "$leaf" ] || return 0
    if [ -n "$suffix" ]; then
      suffix="$leaf/$suffix"
    else
      suffix="$leaf"
    fi
    parent=${probe%/*}
    if [ -z "$parent" ]; then
      parent='/'
    elif [ "$parent" = "$probe" ]; then
      return 0
    fi
    probe="$parent"
  done

  if [ -n "$suffix" ] && [ ! -d "$probe" ]; then
    return 0
  fi
  resolved=$(realpath "$probe" 2>/dev/null || printf '')
  [ -n "$resolved" ] || return 0
  if [ -n "$suffix" ]; then
    resolved="$resolved/$suffix"
  fi
  case "$resolved" in
    "$repo_root/.theorem"|"$repo_root/.theorem/"*) return 0 ;;
    "$repo_root/"*) printf '%s\n' "$resolved" ;;
  esac
}

paths_json=$(
  {
    {
      printf '%s\n' "$direct_paths"
      printf '%s\n' "$patch_paths"
    } | while IFS= read -r path; do
      canonicalize_candidate "$path" "$cwd"
    done
    {
      printf '%s\n' "$shell_paths"
      printf '%s\n' "$committed_paths"
    } | while IFS= read -r path; do
      canonicalize_candidate "$path" "$repo_root"
    done
  } | sort -u | jq -R . | jq -sc .
)

path_count=$(printf '%s' "$paths_json" | jq 'length')
if [ "$path_count" -eq 0 ]; then
  printf '{"continue":true}\n'
  exit 0
fi

touch_key=$(printf '%s\n%s' "$tool_use_id" "$paths_json" | shasum -a 256 | awk '{print $1}')
touch_file="$touch_dir/$touch_key.json"
if [ ! -f "$touch_file" ]; then
  touch_tmp="$touch_file.tmp.$$"
  printf '%s\n' "$paths_json" > "$touch_tmp"
  mv "$touch_tmp" "$touch_file"
fi

args=$(jq -n \
  --arg root "$repo_root" \
  --argjson paths "$paths_json" \
  '{
    root: $root,
    paths: $paths,
    tier_bound: 1,
    materialize: true
  }')
if ! response=$(THEOREM_NATIVE_TIMEOUT_SECONDS=30 theorem_lint_json "check" "$args"); then
  jq -n '{
    continue: true,
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: "RustyRed lint could not inspect the touched files because the local lint MCP endpoint is unavailable."
    }
  }'
  exit 0
fi

lint_payload=$(printf '%s' "$response" | jq -c '.operation_receipt // .lint // .')
context=$(printf '%s' "$lint_payload" | jq -r '
  (.diagnostics // []) as $diagnostics
  | if ($diagnostics | length) == 0 then
      "RustyRed lint found no diagnostics in the touched files."
    else
      "RustyRed lint found \($diagnostics | length) diagnostics in the touched files:\n"
      + (
          $diagnostics[0:40]
          | map("- \(.severity | ascii_upcase) \(.file):\(.span.start_line):\(.span.start_column) [\(.tool)/\(.rule_id)] \(.message)")
          | join("\n")
        )
    end
  | .[0:9500]
')
jq -n --arg context "$context" '{
  continue: true,
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: $context
  }
}'
