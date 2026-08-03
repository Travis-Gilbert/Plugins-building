#!/usr/bin/env bash
# PostToolUse hook: lint only files touched by an edit operation.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

theorem_require_jq || { printf '{"continue":true}\n'; exit 0; }

input=$(theorem_read_stdin)
hook_event_name=$(theorem_jq "$input" '.hook_event_name')
case "$hook_event_name" in
  PostToolUse|PostToolUseFailure) ;;
  *) hook_event_name='PostToolUse' ;;
esac
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
    current_dirty=$(theorem_git_dirty_snapshot_json "$repo_root" 2>/dev/null || printf '[]')
    if [ -n "$tool_use_id" ]; then
      pretool_key=$(printf '%s' "$tool_use_id" | shasum -a 256 | awk '{print $1}')
      pretool_file="$pretool_dir/$pretool_key.json"
      if [ -s "$pretool_file" ]; then
        head_before=$(jq -r '.head_before // empty' "$pretool_file")
        dirty_before=$(jq -c '.dirty_snapshot // []' "$pretool_file" 2>/dev/null || printf '[]')
        shell_paths=$(jq -nr \
          --argjson before "$dirty_before" \
          --argjson current "$current_dirty" '
            $current[] as $item
            | select(any($before[]; .path == $item.path and .fingerprint == $item.fingerprint) | not)
            | $item.path
          ' 2>/dev/null || printf '')
        head_after=$(git -C "$repo_root" rev-parse --verify HEAD 2>/dev/null || printf '')
        if [ -n "$head_before" ] \
          && [ -n "$head_after" ] \
          && [ "$head_before" != "$head_after" ] \
          && git -C "$repo_root" rev-parse --verify "${head_before}^{tree}" >/dev/null 2>&1; then
          committed_paths=$(git -C "$repo_root" diff --name-only --no-renames -z "$head_before" "$head_after" 2>/dev/null \
            | tr '\0' '\n' || printf '')
        fi
      else
        shell_paths=$(printf '%s' "$current_dirty" | jq -r '.[].path' 2>/dev/null || printf '')
      fi
    else
      shell_paths=$(printf '%s' "$current_dirty" | jq -r '.[].path' 2>/dev/null || printf '')
    fi
    ;;
esac

normalize_absolute_path() {
  local raw="$1"
  local normalized='/'
  local component
  local -a components

  IFS='/' read -r -a components <<< "$raw"
  for component in "${components[@]}"; do
    case "$component" in
      ''|.) continue ;;
      ..)
        if [ "$normalized" != '/' ]; then
          normalized=${normalized%/*}
          [ -n "$normalized" ] || normalized='/'
        fi
        ;;
      *)
        if [ "$normalized" = '/' ]; then
          normalized="/$component"
        else
          normalized="$normalized/$component"
        fi
        ;;
    esac
  done
  printf '%s' "$normalized"
}

resolve_physical_path() {
  local probe="$1"
  local resolved parent leaf

  if command -v realpath >/dev/null 2>&1; then
    resolved=$(realpath "$probe" 2>/dev/null || printf '')
    if [ -n "$resolved" ]; then
      printf '%s' "$resolved"
      return 0
    fi
  fi
  if [ -d "$probe" ]; then
    (cd "$probe" 2>/dev/null && pwd -P)
    return
  fi
  [ -L "$probe" ] && return 1
  parent=${probe%/*}
  leaf=${probe##*/}
  [ -n "$parent" ] || parent='/'
  resolved=$(cd "$parent" 2>/dev/null && pwd -P) || return 1
  if [ "$resolved" = '/' ]; then
    printf '/%s' "$leaf"
  else
    printf '%s/%s' "$resolved" "$leaf"
  fi
}

canonicalize_candidate() {
  local raw="$1"
  local base="$2"
  local candidate probe parent leaf suffix resolved

  [ -n "$raw" ] || return 0
  case "$raw" in
    /*) candidate="$raw" ;;
    *) candidate="$base/$raw" ;;
  esac
  candidate=$(normalize_absolute_path "$candidate")

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
  resolved=$(resolve_physical_path "$probe" 2>/dev/null || printf '')
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
  jq -n --arg hook_event_name "$hook_event_name" '{
    continue: true,
    hookSpecificOutput: {
      hookEventName: $hook_event_name,
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
jq -n --arg context "$context" --arg hook_event_name "$hook_event_name" '{
  continue: true,
  hookSpecificOutput: {
    hookEventName: $hook_event_name,
    additionalContext: $context
  }
}'
