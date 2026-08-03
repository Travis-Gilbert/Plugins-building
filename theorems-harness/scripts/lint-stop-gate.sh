#!/usr/bin/env bash
# Stop hook: block only on error-or-higher diagnostics introduced this session.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

theorem_require_jq || { printf '{"continue":true}\n'; exit 0; }

input=$(theorem_read_stdin)
repo_root=$(theorem_repo_root "$input")
sid=$(theorem_session_id "$input")
session_key=$(theorem_session_key "$sid")
state_dir="$repo_root/.theorem/lint/$session_key"
reference_file="$state_dir/baseline-ref.json"
touch_dir="$state_dir/touches"
block_state_file="$state_dir/stop-block-state.json"
stop_hook_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')

clear_block_state() {
  rm -f "$block_state_file"
}

emit_gate_failure() {
  local reason="$1"
  local block_count=0
  local next_count state_tmp

  if [ -s "$block_state_file" ]; then
    block_count=$(jq -r '.block_count // 0' "$block_state_file" 2>/dev/null || printf '0')
    case "$block_count" in
      ''|*[!0-9]*) block_count=0 ;;
    esac
  fi
  if [ "$stop_hook_active" = "true" ] && [ "$block_count" -ge 2 ]; then
    jq -n --arg reason "$reason" '{
      continue: true,
      hookSpecificOutput: {
        hookEventName: "Stop",
        additionalContext: ("RustyRed lint reached its bounded retry limit. The unresolved gate result remains:\n" + $reason)
      }
    }'
    return
  fi

  next_count=$((block_count + 1))
  state_tmp="$block_state_file.tmp.$$"
  jq -n \
    --argjson block_count "$next_count" \
    --arg reason "$reason" \
    '{block_count: $block_count, reason: $reason}' > "$state_tmp"
  mv "$state_tmp" "$block_state_file"
  jq -n --arg reason "$reason" '{decision: "block", reason: $reason}'
}

if [ ! -d "$touch_dir" ]; then
  printf '{"continue":true}\n'
  exit 0
fi

paths_json=$(jq -sc 'add | unique' "$touch_dir"/*.json 2>/dev/null || printf '[]')
path_count=$(printf '%s' "$paths_json" | jq 'length')
if [ "$path_count" -eq 0 ]; then
  printf '{"continue":true}\n'
  exit 0
fi

if [ ! -s "$reference_file" ]; then
  jq -n '{
    continue: true,
    hookSpecificOutput: {
      hookEventName: "Stop",
      additionalContext: "RustyRed lint did not gate completion because no opening baseline was armed."
    }
  }'
  exit 0
fi

baseline_reference=$(jq -r '.baseline_reference // empty' "$reference_file")
if [ -z "$baseline_reference" ]; then
  jq -n '{
    continue: true,
    hookSpecificOutput: {
      hookEventName: "Stop",
      additionalContext: "RustyRed lint did not gate completion because the opening baseline reference is unavailable."
    }
  }'
  exit 0
fi

args=$(jq -n \
  --arg baseline_reference "$baseline_reference" \
  --arg root "$repo_root" \
  --argjson paths "$paths_json" \
  '{
    baseline_reference: $baseline_reference,
    current_scope: {
      root: $root,
      paths: $paths
    },
    tier_bound: 1,
    fail_at_or_above: "error"
  }')
if ! response=$(THEOREM_NATIVE_TIMEOUT_SECONDS=45 theorem_lint_json "gate" "$args"); then
  emit_gate_failure \
    "RustyRed lint cannot prove the session delta because the local lint MCP endpoint is unavailable."
  exit 0
fi

gate=$(printf '%s' "$response" | jq -c '.operation_receipt // .gate // .')
passed=$(printf '%s' "$gate" | jq -r '.passed // .verdict.passed // false')
if [ "$passed" = "true" ]; then
  clear_block_state
  printf '{"continue":true}\n'
  exit 0
fi

reason=$(printf '%s' "$gate" | jq -r '
  (.blocking_introduced // .verdict.blocking_introduced // []) as $blocking
  | "RustyRed lint blocked completion on \($blocking | length) introduced error-or-higher diagnostics:\n"
    + (
        $blocking[0:30]
        | map("- \(.file):\(.span.start_line):\(.span.start_column) [\(.tool)/\(.rule_id)] \(.message)")
        | join("\n")
      )
    + "\nResolve the introduced diagnostics and try to stop again."
')
emit_gate_failure "$reason"
