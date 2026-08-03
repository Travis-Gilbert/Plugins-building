#!/usr/bin/env bash
# PostToolUse hook: lint only files touched by an edit operation.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

theorem_require_jq || { printf '{"continue":true}\n'; exit 0; }

input=$(theorem_read_stdin)
repo_root=$(theorem_repo_root "$input")
cwd=$(theorem_resolve_cwd "$input")
repo_root=$(cd "$repo_root" && pwd -P)
cwd=$(cd "$cwd" && pwd -P)
sid=$(theorem_session_id "$input")
session_key=$(theorem_session_key "$sid")
state_dir="$repo_root/.theorem/lint/$session_key"
touch_dir="$state_dir/touches"
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
    ;;
esac

paths_json=$(
  {
    printf '%s\n' "$direct_paths"
    printf '%s\n' "$patch_paths"
    printf '%s\n' "$shell_paths"
  } | awk -v root="$repo_root" -v cwd="$cwd" '
    NF {
      if ($0 ~ /(^|\/)\.\.(\/|$)/) {
        next
      }
      absolute = substr($0, 1, 1) == "/" ? $0 : cwd "/" $0
      if (index(absolute, root "/") == 1) {
        print absolute
      }
    }
  ' | sort -u | jq -R . | jq -sc .
)

path_count=$(printf '%s' "$paths_json" | jq 'length')
if [ "$path_count" -eq 0 ]; then
  printf '{"continue":true}\n'
  exit 0
fi

tool_use_id=$(theorem_jq "$input" '.tool_use_id')
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
