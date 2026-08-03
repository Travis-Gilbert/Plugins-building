#!/usr/bin/env bash
# Opt-in live oracle for the real local lint gateway and delta gate.

set -euo pipefail

if [ -z "${THEOREM_LINT_MCP_URL:-}" ]; then
  printf 'SKIP: set THEOREM_LINT_MCP_URL to the authenticated local /mcp endpoint\n'
  exit 77
fi

plugin_root=$(cd "$(dirname "$0")/.." && pwd)
fixture_root=$(mktemp -d)
trap 'find "$fixture_root" -depth -delete 2>/dev/null || true' EXIT

repo="$fixture_root/repo"
git -C "$fixture_root" init -q repo
printf 'fn main() {}\n' > "$repo/main.rs"
git -C "$repo" add main.rs
git -C "$repo" -c user.name=Test -c user.email=test@example.invalid commit -qm initial

session_id="lint-live-$$"
session_input=$(jq -n --arg cwd "$repo" --arg sid "$session_id" '{
  session_id: $sid,
  cwd: $cwd,
  hook_event_name: "SessionStart"
}')
start_output=$(printf '%s' "$session_input" | "$plugin_root/scripts/lint-sessionstart.sh")
printf '%s' "$start_output" | jq -e '
  .hookSpecificOutput.additionalContext | contains("captured the opening baseline")
' >/dev/null

printf '// bad \342\200\224 punctuation\nfn main() {}\n' > "$repo/main.rs"
post_input=$(jq -n --arg cwd "$repo" --arg sid "$session_id" --arg path "$repo/main.rs" '{
  session_id: $sid,
  cwd: $cwd,
  hook_event_name: "PostToolUse",
  tool_name: "Write",
  tool_use_id: "live-write-1",
  tool_input: {file_path: $path}
}')
post_output=$(printf '%s' "$post_input" | "$plugin_root/scripts/lint-posttool.sh")
printf '%s' "$post_output" | jq -e '
  .hookSpecificOutput.additionalContext | contains("rust-em-dash")
' >/dev/null

stop_input=$(jq -n --arg cwd "$repo" --arg sid "$session_id" '{
  session_id: $sid,
  cwd: $cwd,
  hook_event_name: "Stop",
  stop_hook_active: false
}')
blocked=$(printf '%s' "$stop_input" | "$plugin_root/scripts/lint-stop-gate.sh")
printf '%s' "$blocked" | jq -e '.decision == "block"' >/dev/null

printf 'fn main() {}\n' > "$repo/main.rs"
printf '%s' "$post_input" | "$plugin_root/scripts/lint-posttool.sh" >/dev/null
passed=$(printf '%s' "$stop_input" | "$plugin_root/scripts/lint-stop-gate.sh")
printf '%s' "$passed" | jq -e '.continue == true' >/dev/null

printf '// existing \342\200\224 punctuation\nfn main() {}\n' > "$repo/main.rs"
existing_sid="lint-live-existing-$$"
existing_start=$(printf '%s' "$session_input" | jq --arg sid "$existing_sid" '.session_id = $sid')
existing_start_output=$(
  printf '%s' "$existing_start" | "$plugin_root/scripts/lint-sessionstart.sh"
)
printf '%s' "$existing_start_output" | jq -e '
  .hookSpecificOutput.additionalContext | contains("captured the opening baseline")
' >/dev/null
printf '\n' >> "$repo/main.rs"
existing_post=$(printf '%s' "$post_input" | jq --arg sid "$existing_sid" '
  .session_id = $sid | .tool_use_id = "live-write-existing"
')
printf '%s' "$existing_post" | "$plugin_root/scripts/lint-posttool.sh" >/dev/null
existing_stop=$(printf '%s' "$stop_input" | jq --arg sid "$existing_sid" '.session_id = $sid')
existing_pass=$(printf '%s' "$existing_stop" | "$plugin_root/scripts/lint-stop-gate.sh")
printf '%s' "$existing_pass" | jq -e '.continue == true' >/dev/null

printf 'live lint hook delta oracle passed\n'
