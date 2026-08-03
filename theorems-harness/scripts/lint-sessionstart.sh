#!/usr/bin/env bash
# SessionStart hook: capture one immutable tier-0/tier-1 lint baseline.

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

mkdir -p "$state_dir"
if [ -s "$reference_file" ]; then
  baseline_reference=$(jq -r '.baseline_reference // empty' "$reference_file" 2>/dev/null || printf '')
  jq -n --arg baseline_reference "$baseline_reference" '{
    continue: true,
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ("RustyRed lint baseline reused for this session: " + $baseline_reference)
    }
  }'
  exit 0
fi

lock_dir="$state_dir/capture.lock"
lock_pid_file="$lock_dir/pid"

cleanup_capture_lock() {
  local owner_pid=''
  if [ -f "$lock_pid_file" ]; then
    owner_pid=$(cat "$lock_pid_file" 2>/dev/null || printf '')
  fi
  if [ "$owner_pid" = "$$" ]; then
    rm -f "$lock_pid_file"
    rmdir "$lock_dir" 2>/dev/null || true
  fi
}

capture_lock_is_stale() {
  local owner_pid=''
  if [ -f "$lock_pid_file" ]; then
    owner_pid=$(cat "$lock_pid_file" 2>/dev/null || printf '')
    case "$owner_pid" in
      ''|*[!0-9]*) return 0 ;;
    esac
    if kill -0 "$owner_pid" 2>/dev/null; then
      return 1
    fi
    return 0
  fi
  find "$lock_dir" -prune -mmin +1 -print 2>/dev/null | grep -q .
}

if ! mkdir "$lock_dir" 2>/dev/null; then
  if capture_lock_is_stale; then
    rm -f "$lock_pid_file"
    rmdir "$lock_dir" 2>/dev/null || true
  fi
  if ! mkdir "$lock_dir" 2>/dev/null; then
    printf '{"continue":true}\n'
    exit 0
  fi
fi
printf '%s\n' "$$" > "$lock_pid_file"
trap cleanup_capture_lock EXIT
trap 'cleanup_capture_lock; exit 0' HUP INT TERM

args=$(jq -n \
  --arg root "$repo_root" \
  --arg baseline_key "$session_key" \
  '{
    root: $root,
    paths: [$root],
    tier_bound: 1,
    capture_baseline: true,
    baseline_key: $baseline_key,
    materialize: true
  }')

if ! response=$(THEOREM_NATIVE_TIMEOUT_SECONDS=45 theorem_lint_json "check" "$args"); then
  jq -n '{
    continue: true,
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: "RustyRed lint baseline was not captured because the local lint MCP endpoint is unavailable."
    }
  }'
  exit 0
fi

lint_payload=$(printf '%s' "$response" | jq -c '.operation_receipt // .lint // .')
baseline_reference=$(printf '%s' "$lint_payload" | jq -r '.baseline_reference // empty')
if [ -z "$baseline_reference" ]; then
  jq -n '{
    continue: true,
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: "RustyRed lint returned no immutable baseline reference; the session gate is not armed."
    }
  }'
  exit 0
fi

snapshot_hash=$(printf '%s' "$lint_payload" | shasum -a 256 | awk '{print $1}')
snapshot_file="$state_dir/baseline-$snapshot_hash.json"
snapshot_tmp="$snapshot_file.tmp.$$"
printf '%s\n' "$lint_payload" > "$snapshot_tmp"
mv "$snapshot_tmp" "$snapshot_file"
chmod 0444 "$snapshot_file" 2>/dev/null || true

reference_tmp="$reference_file.tmp.$$"
jq -n \
  --arg baseline_reference "$baseline_reference" \
  --arg snapshot_file "$snapshot_file" \
  --arg snapshot_sha256 "$snapshot_hash" \
  '{
    baseline_reference: $baseline_reference,
    snapshot_file: $snapshot_file,
    snapshot_sha256: $snapshot_sha256
  }' > "$reference_tmp"
mv "$reference_tmp" "$reference_file"

diagnostic_count=$(printf '%s' "$lint_payload" | jq -r '(.diagnostics // []) | length')
jq -n \
  --arg baseline_reference "$baseline_reference" \
  --arg diagnostic_count "$diagnostic_count" \
  '{
    continue: true,
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ("RustyRed lint captured the opening baseline " + $baseline_reference + " with " + $diagnostic_count + " diagnostics.")
    }
  }'
