#!/usr/bin/env bash
# Oracle for baseline reuse, touched-file scoping, context injection, and Stop.

set -euo pipefail

plugin_root=$(cd "$(dirname "$0")/.." && pwd)
fixture_root=$(mktemp -d)
trap 'find "$fixture_root" -depth -delete 2>/dev/null || true' EXIT

jq -e '
  any(.hooks.PostToolUse[];
    ((.matcher // "") | test("apply_patch"))
    and ((.matcher // "") | test("Bash"))
    and any(.hooks[]; .command | contains("lint-posttool.sh")))
  and all(.hooks.PreToolUse[]; all(.hooks[]; (.command | contains("lint-posttool.sh")) | not))
' "$plugin_root/hooks/hooks.json" >/dev/null
jq -e '
  any(.hooks.PostToolUse[];
    ((.matcher // "") | test("apply_patch"))
    and ((.matcher // "") | test("exec_command"))
    and any(.hooks[]; .command | contains("lint-posttool.sh")))
' "$plugin_root/hooks/codex-hooks.json" >/dev/null

repo="$fixture_root/repo"
mkdir -p "$repo/src"
git -C "$fixture_root" init -q repo
printf 'fn main() {}\n' > "$repo/src/main.rs"
git -C "$repo" add src/main.rs
git -C "$repo" -c user.name=Test -c user.email=test@example.invalid commit -qm initial
repo=$(git -C "$repo" rev-parse --show-toplevel)

export FAKE_LINT_LOG="$fixture_root/lint-calls.jsonl"
export FAKE_GATE_PASS=true
curl() {
  local payload=""
  while [ "$#" -gt 0 ]; do
    if [ "$1" = "-d" ]; then
      payload="$2"
      shift 2
      continue
    fi
    shift
  done
  local operation
  operation=$(printf '%s' "$payload" | jq -r '.params.arguments.affordance_id | split(".")[-1]')
  printf '%s\n' "$payload" >> "$FAKE_LINT_LOG"
  case "$operation" in
    check)
      jq -n --arg file "$repo/src/main.rs" '{
        jsonrpc: "2.0",
        id: 1,
        result: {
          structuredContent: {
            operation_receipt: {
              baseline_reference: "lint:baseline:test",
              diagnostics: [{
                tool: "ast-grep",
                version: "0.1.0",
                rule_id: "fixture-error",
                severity: "error",
                artifact_class: "code",
                file: $file,
                span: {
                  start_line: 1,
                  start_column: 1,
                  end_line: 1,
                  end_column: 3
                },
                message: "fixture diagnostic",
                fingerprint: "diag:fixture"
              }]
            }
          }
        }
      }'
      ;;
    gate)
      if [ "$FAKE_GATE_PASS" = "true" ]; then
        jq -n '{
          jsonrpc: "2.0",
          id: 1,
          result: {
            structuredContent: {
              operation_receipt: {
                passed: true,
                blocking_introduced: []
              }
            }
          }
        }'
      else
        jq -n --arg file "$repo/src/main.rs" '{
          jsonrpc: "2.0",
          id: 1,
          result: {
            structuredContent: {
              operation_receipt: {
                passed: false,
                blocking_introduced: [{
                  tool: "ast-grep",
                  rule_id: "fixture-error",
                  file: $file,
                  span: {start_line: 1, start_column: 1},
                  message: "introduced fixture diagnostic"
                }]
              }
            }
          }
        }'
      fi
      ;;
    *)
      return 1
      ;;
  esac
}
export -f curl
export repo

session_input=$(jq -n --arg cwd "$repo" '{
  session_id: "lint-hook-test",
  cwd: $cwd,
  hook_event_name: "SessionStart"
}')
first_start=$(printf '%s' "$session_input" | "$plugin_root/scripts/lint-sessionstart.sh")
second_start=$(printf '%s' "$session_input" | "$plugin_root/scripts/lint-sessionstart.sh")
printf '%s' "$first_start" | jq -e '.continue == true' >/dev/null
printf '%s' "$second_start" | jq -e '.hookSpecificOutput.additionalContext | contains("reused")' >/dev/null
capture_count=$(jq -r '.params.arguments.arguments.capture_baseline // false' "$FAKE_LINT_LOG" | grep -c true)
[ "$capture_count" -eq 1 ]
baseline_tier=$(jq -r 'select(.params.arguments.arguments.capture_baseline == true) | .params.arguments.arguments.tier_bound' "$FAKE_LINT_LOG")
[ "$baseline_tier" -eq 1 ]

post_input=$(jq -n --arg cwd "$repo" '{
  session_id: "lint-hook-test",
  cwd: $cwd,
  hook_event_name: "PostToolUse",
  tool_name: "apply_patch",
  tool_use_id: "patch-1",
  tool_input: {
    patch: "*** Begin Patch\n*** Update File: src/main.rs\n@@\n-fn main() {}\n+fn main() { panic!(); }\n*** End Patch\n"
  }
}')
post_output=$(printf '%s' "$post_input" | "$plugin_root/scripts/lint-posttool.sh")
printf '%s' "$post_output" | jq -e '
  .hookSpecificOutput.hookEventName == "PostToolUse"
  and (.hookSpecificOutput.additionalContext | contains("fixture-error"))
' >/dev/null
post_paths=$(jq -sc '.[-1].params.arguments.arguments.paths' "$FAKE_LINT_LOG")
[ "$post_paths" = "[\"$repo/src/main.rs\"]" ]

mkdir -p "$repo/pkg/src"
relative_input=$(jq -n --arg cwd "$repo/pkg" '{
  session_id: "lint-hook-test",
  cwd: $cwd,
  hook_event_name: "PostToolUse",
  tool_name: "apply_patch",
  tool_use_id: "patch-relative",
  tool_input: {
    patch: "*** Begin Patch\n*** Update File: src/nested.rs\n@@\n-old\n+new\n*** End Patch\n"
  }
}')
printf '%s' "$relative_input" | "$plugin_root/scripts/lint-posttool.sh" >/dev/null
relative_paths=$(jq -sc '.[-1].params.arguments.arguments.paths' "$FAKE_LINT_LOG")
[ "$relative_paths" = "[\"$repo/pkg/src/nested.rs\"]" ]

move_input=$(jq -n --arg cwd "$repo" '{
  session_id: "lint-hook-test",
  cwd: $cwd,
  hook_event_name: "PostToolUse",
  tool_name: "apply_patch",
  tool_use_id: "patch-move",
  tool_input: {
    patch: "*** Begin Patch\n*** Update File: src/main.rs\n*** Move to: src/moved.rs\n@@\n-old\n+new\n*** End Patch\n"
  }
}')
printf '%s' "$move_input" | "$plugin_root/scripts/lint-posttool.sh" >/dev/null
move_paths=$(jq -sc '.[-1].params.arguments.arguments.paths' "$FAKE_LINT_LOG")
[ "$move_paths" = "[\"$repo/src/main.rs\",\"$repo/src/moved.rs\"]" ]

printf 'fn generated() { panic!(); }\n' > "$repo/src/shell.rs"
shell_input=$(jq -n --arg cwd "$repo" '{
  session_id: "lint-hook-test",
  cwd: $cwd,
  hook_event_name: "PostToolUse",
  tool_name: "functions.exec_command",
  tool_use_id: "shell-1",
  tool_input: {cmd: "formatter --write src/shell.rs"}
}')
printf '%s' "$shell_input" | "$plugin_root/scripts/lint-posttool.sh" >/dev/null
shell_paths=$(jq -sc '.[-1].params.arguments.arguments.paths' "$FAKE_LINT_LOG")
[ "$shell_paths" = "[\"$repo/src/shell.rs\"]" ]

calls_before_escape=$(wc -l < "$FAKE_LINT_LOG" | tr -d '[:space:]')
escape_input=$(jq -n --arg cwd "$repo" '{
  session_id: "lint-hook-test",
  cwd: $cwd,
  hook_event_name: "PostToolUse",
  tool_name: "apply_patch",
  tool_use_id: "patch-escape",
  tool_input: {
    file_path: "../outside.rs",
    patch: "*** Begin Patch\n*** Update File: ../outside.rs\n@@\n-old\n+new\n*** End Patch\n"
  }
}')
escape_output=$(printf '%s' "$escape_input" | "$plugin_root/scripts/lint-posttool.sh")
printf '%s' "$escape_output" | jq -e '.continue == true' >/dev/null
calls_after_escape=$(wc -l < "$FAKE_LINT_LOG" | tr -d '[:space:]')
[ "$calls_before_escape" -eq "$calls_after_escape" ]

stop_input=$(jq -n --arg cwd "$repo" '{
  session_id: "lint-hook-test",
  cwd: $cwd,
  hook_event_name: "Stop",
  stop_hook_active: false
}')
pass_output=$(printf '%s' "$stop_input" | "$plugin_root/scripts/lint-stop-gate.sh")
printf '%s' "$pass_output" | jq -e '.continue == true' >/dev/null
gate_tier=$(jq -r 'select(.params.arguments.affordance_id == "lint.gate") | .params.arguments.arguments.tier_bound' "$FAKE_LINT_LOG" | tail -n 1)
[ "$gate_tier" -eq 1 ]

export FAKE_GATE_PASS=false
block_output=$(printf '%s' "$stop_input" | "$plugin_root/scripts/lint-stop-gate.sh")
printf '%s' "$block_output" | jq -e '
  .decision == "block"
  and (.reason | contains("introduced fixture diagnostic"))
' >/dev/null

active_stop=$(printf '%s' "$stop_input" | jq '.stop_hook_active = true')
active_output=$(printf '%s' "$active_stop" | "$plugin_root/scripts/lint-stop-gate.sh")
printf '%s' "$active_output" | jq -e '.continue == true' >/dev/null

missing_sid="lint-hook-missing-baseline"
# shellcheck disable=SC1091
source "$plugin_root/scripts/lib.sh"
missing_key=$(theorem_session_key "$missing_sid")
missing_touch_dir="$repo/.theorem/lint/$missing_key/touches"
mkdir -p "$missing_touch_dir"
printf '["%s"]\n' "$repo/src/main.rs" > "$missing_touch_dir/touch.json"
missing_input=$(jq -n --arg cwd "$repo" --arg sid "$missing_sid" '{
  session_id: $sid,
  cwd: $cwd,
  hook_event_name: "Stop",
  stop_hook_active: false
}')
missing_output=$(printf '%s' "$missing_input" | "$plugin_root/scripts/lint-stop-gate.sh")
printf '%s' "$missing_output" | jq -e '
  .decision == "block"
  and (.reason | contains("baseline was not captured"))
' >/dev/null

printf 'lint hook lifecycle oracle passed\n'
