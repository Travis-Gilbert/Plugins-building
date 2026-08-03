#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

readonly PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly CONTRACT="$PLUGIN_ROOT/references/GRAPH_LISP_CAPABILITY.md"
readonly SKILL="$PLUGIN_ROOT/skills/graph-lisp/SKILL.md"

fail() {
  printf 'graph-lisp surface check failed: %s\n' "$*" >&2
  exit 1
}

require_text() {
  local file=$1
  local expected=$2
  grep -Fq "$expected" "$file" \
    || fail "${file#$PLUGIN_ROOT/} does not teach $expected"
}

for file in "$CONTRACT" "$SKILL"; do
  [[ -f "$file" ]] || fail "missing ${file#$PLUGIN_ROOT/}"
  for token in \
    'execute_capability' \
    'CapabilityRequest' \
    'CapabilityLimits' \
    'CapabilityPolicy' \
    'CapabilityReceipt' \
    '`read`' \
    '`eval`' \
    '`diff`' \
    '`explain`' \
    '`dynamic_call`' \
    'external_executor_required' \
    'graphLispRead' \
    'graphLispEval' \
    'graphLispDiff' \
    'graphLispExplain' \
    'graph-lisp.read' \
    'graph-lisp.eval' \
    'graph-lisp.diff' \
    'graph-lisp.explain'; do
    require_text "$file" "$token"
  done
done

for contract_token in \
  '64 KiB' \
  '10,000' \
  '1,000,000' \
  'TypedValue' \
  'input_anchor' \
  'outcome_anchor' \
  'invalid_graph_version' \
  'fuel_limit_exceeded' \
  'permission_denied' \
  'fuel_exhausted' \
  'replay_bytes()' \
  "backend's committed graph state" \
  'public parity fixture' \
  'permanently read-only unseeded tenant can complete'; do
  require_text "$CONTRACT" "$contract_token"
done

for surface in \
  "$PLUGIN_ROOT/README.md" \
  "$PLUGIN_ROOT/references/PLUGIN_INVENTORY.md" \
  "$PLUGIN_ROOT/references/ROUTING.md" \
  "$PLUGIN_ROOT/skills/theorems-harness/SKILL.md"; do
  require_text "$surface" 'GRAPH_LISP_CAPABILITY.md'
  require_text "$surface" 'execute_capability'
  require_text "$surface" 'external_executor_required'
done

readonly INVENTED_PATTERN='\b(graph_lisp_(read|eval|diff|explain)|GraphLisp(Read|Eval|Diff|Explain))\b'
if command -v rg >/dev/null 2>&1; then
  if rg -n "$INVENTED_PATTERN" \
    "$PLUGIN_ROOT/README.md" "$PLUGIN_ROOT/commands" "$PLUGIN_ROOT/references" "$PLUGIN_ROOT/skills" \
    --glob '!PLANNED-CAPABILITY-PLUGIN-IDEAS.md'; then
    fail 'active teaching names an invented remote Graph Lisp surface'
  fi
elif grep -ERn '(graph_lisp_(read|eval|diff|explain)|GraphLisp(Read|Eval|Diff|Explain))' \
  "$PLUGIN_ROOT/README.md" "$PLUGIN_ROOT/commands" "$PLUGIN_ROOT/references" "$PLUGIN_ROOT/skills" \
  | grep -v 'PLANNED-CAPABILITY-PLUGIN-IDEAS.md'; then
  fail 'active teaching names an invented remote Graph Lisp surface'
fi

if grep -Eq 'no (MCP|GraphQL|dynamic)|has no .*remote projection|not registered in MCP' \
  "$CONTRACT" "$SKILL"; then
  fail 'active teaching still denies the implemented remote Graph Lisp projection'
fi

if grep -Eq 'may not discover|require native catalog discovery work|until the native catalog is materialized' \
  "$CONTRACT" "$SKILL"; then
  fail 'active teaching still denies write-free discovery for an unseeded read-only tenant'
fi

printf 'graph-lisp teaching surface: complete\n'
