#!/usr/bin/env bash
# PreToolUse hook: anchor Git state before a shell command can edit and commit.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

theorem_require_jq || { printf '{"continue":true}\n'; exit 0; }

input=$(theorem_read_stdin)
tool_name=$(printf '%s' "$input" | jq -r '
  if (.tool | type) == "object" then (.tool.name // "")
  elif (.tool | type) == "string" then .tool
  else (.tool_name // .name // "")
  end
' 2>/dev/null || printf '')
case "$tool_name" in
  Bash|exec_command|functions.exec_command) ;;
  *)
    printf '{"continue":true}\n'
    exit 0
    ;;
esac

repo_root=$(theorem_repo_root "$input")
repo_root=$(cd "$repo_root" && pwd -P)
head_before=$(git -C "$repo_root" rev-parse --verify HEAD 2>/dev/null || printf '')
tool_use_id=$(theorem_jq "$input" '.tool_use_id')
if [ -z "$head_before" ] || [ -z "$tool_use_id" ]; then
  printf '{"continue":true}\n'
  exit 0
fi

sid=$(theorem_session_id "$input")
session_key=$(theorem_session_key "$sid")
pretool_dir="$repo_root/.theorem/lint/$session_key/pretool"
mkdir -p "$pretool_dir"
pretool_key=$(printf '%s' "$tool_use_id" | shasum -a 256 | awk '{print $1}')
pretool_file="$pretool_dir/$pretool_key.json"
pretool_tmp="$pretool_file.tmp.$$"
jq -n \
  --arg tool_use_id "$tool_use_id" \
  --arg head_before "$head_before" \
  '{tool_use_id: $tool_use_id, head_before: $head_before}' > "$pretool_tmp"
mv "$pretool_tmp" "$pretool_file"

printf '{"continue":true}\n'
