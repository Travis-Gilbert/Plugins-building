#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

readonly PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly CONTRACT="$PLUGIN_ROOT/references/VERIFIED_COGNITION_CAPABILITY.md"
readonly SKILL="$PLUGIN_ROOT/skills/verified-cognition/SKILL.md"

fail() {
  printf 'verified-cognition capability surface check failed: %s\n' "$*" >&2
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
    'constraint.check' \
    'proof_eligible' \
    'recordVerification' \
    'verification_record' \
    'verificationExplain' \
    'verification_explain' \
    'reverseEngineer' \
    'reverse_engineer_' \
    'unknowns' \
    'unresolved_obligations' \
    'not_run' \
    'patch_proposed' \
    'spawn_verify' \
    'submit_verify' \
    'prove' \
    'done'; do
    require_text "$file" "$token"
  done
done

for token in \
  'source tree implements' \
  'receipt-led orchestration protocol' \
  'eight-case adverse-fixture contract checker' \
  'not yet exposed through MCP' \
  'does not persist' \
  'authoritative receipt loading'; do
  require_text "$SKILL" "$token"
done

for token in \
  'rustyred-thg-mcp/src/verified_cognition.rs' \
  'scripts/check-verified-cognition-contracts.sh' \
  'decision' \
  'consistency' \
  'reconstruction' \
  'repair' \
  'voice' \
  'SHA-256-linked receipt chain' \
  'no monolithic `verifiedCognition` tool'; do
  require_text "$CONTRACT" "$token"
done

if grep -Eiq \
  '(orchestration|orchestrator(s)?|contract checker)[^.]*((unimplemented)|(not[[:space:]]+implemented)|((do(es)?)[[:space:]]+not[[:space:]]+(yet[[:space:]]+)?exist))' \
  "$CONTRACT" "$SKILL"; then
  fail 'active teaching still denies the implemented source orchestration contract'
fi

for surface in \
  "$PLUGIN_ROOT/README.md" \
  "$PLUGIN_ROOT/references/PLUGIN_INVENTORY.md" \
  "$PLUGIN_ROOT/references/ROUTING.md" \
  "$PLUGIN_ROOT/skills/theorems-harness/SKILL.md"; do
  require_text "$surface" 'VERIFIED_COGNITION_CAPABILITY.md'
  require_text "$surface" 'verified-cognition'
  require_text "$surface" 'constraint.check'
done

printf 'verified-cognition capability teaching surface: complete\n'
