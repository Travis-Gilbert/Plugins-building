#!/usr/bin/env bash
# Stop hook: block only on error-or-higher diagnostics introduced this session.

set -euo pipefail

# shellcheck disable=SC1091
source "$(dirname "$0")/lib.sh"

theorem_require_jq || { printf '{"continue":true}\n'; exit 0; }

input=$(theorem_read_stdin)
stop_hook_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false')
if [ "$stop_hook_active" = "true" ]; then
  printf '{"continue":true}\n'
  exit 0
fi
repo_root=$(theorem_repo_root "$input")
sid=$(theorem_session_id "$input")
session_key=$(theorem_session_key "$sid")
state_dir="$repo_root/.theorem/lint/$session_key"
reference_file="$state_dir/baseline-ref.json"
touch_dir="$state_dir/touches"

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
    decision: "block",
    reason: "RustyRed lint cannot prove the session delta because the opening baseline was not captured."
  }'
  exit 0
fi

baseline_reference=$(jq -r '.baseline_reference // empty' "$reference_file")
if [ -z "$baseline_reference" ]; then
  jq -n '{
    decision: "block",
    reason: "RustyRed lint cannot prove the session delta because the opening baseline reference is missing."
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
  jq -n '{
    decision: "block",
    reason: "RustyRed lint cannot prove the session delta because the local lint MCP endpoint is unavailable."
  }'
  exit 0
fi

gate=$(printf '%s' "$response" | jq -c '.operation_receipt // .gate // .')
passed=$(printf '%s' "$gate" | jq -r '.passed // .verdict.passed // false')
if [ "$passed" = "true" ]; then
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
jq -n --arg reason "$reason" '{
  decision: "block",
  reason: $reason
}'
