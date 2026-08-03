#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

readonly PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly CONTRACT="$PLUGIN_ROOT/references/DATA_RECONSTRUCTION_CAPABILITY.md"
readonly SKILL="$PLUGIN_ROOT/skills/data-reconstruction/SKILL.md"

fail() {
  printf 'data-reconstruction capability surface check failed: %s\n' "$*" >&2
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
    'dataSchema' \
    'query_data' \
    'dataRegistry' \
    'data_registry_get' \
    'dataRegistries' \
    'data_registry_list' \
    'publishDataRegistry' \
    'data_registry_publish' \
    'harnessKgStatus' \
    'harness_kg_status' \
    'datawave_ingest' \
    'resolve_ingest' \
    'resolve_entities' \
    'resolve_explain' \
    'reverseEngineerCompose' \
    'reverse_engineer_compose' \
    'reverseEngineerValidate' \
    'reverse_engineer_validate' \
    'source.sha' \
    'unknowns' \
    'unresolved_obligations' \
    'not_run'; do
    require_text "$file" "$token"
  done
done

for token in \
  'upsertDataView' \
  'harnessKgExplainEdge' \
  'memory_dedup_report' \
  'reconstruct_binary' \
  'reverseEngineerPort' \
  'GraphQL bridges for DATAWAVE and resolve' \
  'pinned end-to-end reconstruction oracle'; do
  require_text "$CONTRACT" "$token"
done

for surface in \
  "$PLUGIN_ROOT/README.md" \
  "$PLUGIN_ROOT/references/PLUGIN_INVENTORY.md" \
  "$PLUGIN_ROOT/references/ROUTING.md" \
  "$PLUGIN_ROOT/skills/theorems-harness/SKILL.md"; do
  require_text "$surface" 'DATA_RECONSTRUCTION_CAPABILITY.md'
  require_text "$surface" 'reverseEngineerCompose'
  require_text "$surface" 'resolve_ingest'
done

require_text "$CONTRACT" 'There is no GraphQL or dynamic projection.'
require_text "$CONTRACT" 'There is no `datawaveIngest` GraphQL field.'
require_text "$CONTRACT" 'No stable dynamic reconstruction projection is taught here.'

if grep -Fq -- '- a persistent declarative `DataRegistry`;' "$CONTRACT"; then
  fail 'contract still teaches the implemented persistent DataRegistry as absent'
fi

printf 'data-reconstruction capability teaching surface: complete\n'
