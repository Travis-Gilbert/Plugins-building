# Data, Instant-KG, Resolve, and Reconstruction Capability

This family has several real projections. Do not flatten them into one invented
"data" or "reconstruction" service. Prefer typed GraphQL where it exists, use
the named flat tools for compatibility or flat-only work, and preserve every
receipt, source anchor, unknown, and unresolved obligation.

## Data API

The typed GraphQL Data domain wraps the same `query_data` handler as the flat
MCP tool.

| Purpose | GraphQL | Flat operation |
|---|---|---|
| Describe the envelope | `dataSchema` | `query_data` with `operation: "schema"` |
| List records | `dataRecords` | `query_data` with `operation: "records"` |
| Read one record | `dataRecord` | `query_data` with `operation: "record"` |
| Read record links | `dataLinks` | `query_data` with `operation: "links"` |
| Flexible query | `dataQuery` | `query_data` with `operation: "query"` |
| Memory-oriented retrieval | `dataRetrieve` | `query_data` with `operation: "retrieve"` |
| List saved views | `dataViews` | `query_data` with `operation: "views"` |
| Read or run a saved view | `dataView` | `query_data` with `operation: "view"` |
| Save a view | `upsertDataView` mutation | `query_data` with `operation: "upsert_view"` |

`dataRecords`, `dataQuery`, and `dataRetrieve` require positive limits. Cursor
paging uses `offset:<number>`. Link hydration is explicit. An unconstrained
flat query is refused unless it includes an id, collection, label, filters, or
`broad_scan: true`.

The Data API is an envelope over graph-backed records and saved views. It is
not the persistent declarative `DataRegistry`. Flat-only companion
packets such as `retrieve_memory`, `turn_start`, and `evidence_bundle` keep
their separate memory/work-queue semantics.

## Persistent DataRegistry

The DataRegistry durably publishes immutable, content-addressed source
manifests and their admission receipts. It is distinct from the flexible Data
API above.

| Purpose | GraphQL | Flat operation |
|---|---|---|
| Read one registered source | `dataRegistry` | `data_registry_get` |
| List registered sources | `dataRegistries` | `data_registry_list` |
| Publish a source manifest | `publishDataRegistry` | `data_registry_publish` |

A source manifest binds source id/kind, pinned locator, content anchor, schema
version, collections, metadata, and explicit obligations. Publication derives
tenant, actor, and binding from admitted identity and atomically stores the
manifest, registry entry, graph edges, and publication receipt. Repeating the
same manifest is idempotent. A different immutable manifest for the same source
creates a visible conflict and leaves the original registered manifest intact.
Reads are bounded, and `unknown` obligations remain first-class.

## Instant KG

The six typed GraphQL reads have exact flat compatibility tools:

| GraphQL query | Flat tool |
|---|---|
| `harnessKgStatus` | `harness_kg_status` |
| `harnessKgSearch` | `harness_kg_search` |
| `harnessKgPpr` | `harness_kg_ppr` |
| `harnessKgImpact` | `harness_kg_impact` |
| `harnessKgRelatedObjects` | `harness_kg_related_objects` |
| `harnessKgExplainEdge` | `harness_kg_explain_edge` |

These are reads over the instant-KG view. They are not raw graph writes or a
general entity-resolution API. `harnessKgImpact` requires a seed or a
resolvable symbol name.

## Entity resolution

Resolution is currently flat-only. There is no GraphQL or dynamic projection.

- `resolve_ingest` writes at most 1,000 records per call into the tenant's
  graph-owned, generation-backed resolver. It refuses unknown helper,
  resolution, and record fields; blocking fields must be indexed; the tenant's
  effective configuration is immutable; and an existing record id cannot be
  silently replaced with different content. The resolver caps total records at
  100,000 and retries generation commit conflicts at most eight times.
- `resolve_entities` reads at most 100 deterministic entities and golden
  records, optionally selecting the entity for one `record_id`.
- `resolve_explain` requires exactly one of `record_id` or `entity_id` and
  returns at most 256 relevant proofs against the full receipt root.
- `memory_dedup_report` is a bounded, read-only duplicate-candidate report over
  `MemoryDocument` title and actor facts. It does not merge or delete memory.

Do not invent `resolveEntities`, `resolveIngest`, or another GraphQL spelling.

## DATAWAVE intake

`datawave_ingest` is also flat-only. Its bounded operations are `describe`,
`record`, `batch`, `lookup`, and `intersect`. It turns records into normalized
field facts and declared entity edges through a `csv`, `json`, or `mapped`
helper; the engine performs normalization. `lookup` and `intersect` read those
facts by field/value. There is no `datawaveIngest` GraphQL field.

## Source reconstruction

All seven typed GraphQL fields are mutations because every stage enters through
compose and writes compiler, DATAWAVE, and compose receipts. Their exact flat
counterparts are:

| GraphQL mutation | Flat tool |
|---|---|
| `reverseEngineerCompose` | `reverse_engineer_compose` |
| `reverseEngineerSlice` | `reverse_engineer_slice` |
| `reverseEngineerBehaviorIr` | `reverse_engineer_behavior_ir` |
| `reverseEngineerTargetPlan` | `reverse_engineer_target_plan` |
| `reverseEngineerEmit` | `reverse_engineer_emit` |
| `reverseEngineerValidate` | `reverse_engineer_validate` |
| `reverseEngineerPort` | `reverse_engineer_port` |

Every typed call requires `repo` or a repository-bearing `source`. Target plan,
emit, validate, and port also require `target`. The typed result reports
`tenant`, `operation`, `command`, `writesGraph`, `affordanceId`, `engine`, and
the stage `result`.

The GraphQL boundary limits text to 4 KiB, SHA values to 256 bytes, lists to
256 items, symbols to 100,000, features to 512, patterns to 100, files to 512,
and DATAWAVE facts to 100,000. Introspect the live schema before constructing
enums for target language or idiom level.

Three broader reconstruction surfaces remain flat-only:

- `reconstruct` composes `compose`, `binary`, `datawave`, `source_to_binary`,
  `slice`, `behavior_ir`, `target_plan`, `emit`, `validate`, `port`, and a
  separate `generate` path. Generation currently supports only
  `building-fixture` and `creature` and requires `subject_id`.
- `reconstruct_binary` supports `load`, `analyze`, `lift`, `graph_write`,
  `components_recover`, `plan_compile`, `instruction_get`, `validate`, and
  `receipt_write`. Writes remain subject to MCP write mode.
- `datawave_ingest` is the intake surface described above.

Do not treat internal affordance ids returned by these handlers as proof that
`tool_search` / `describe` / `invoke` registers a reconstruction capability.
No stable dynamic reconstruction projection is taught here.

## Pinned source and obligation discipline

For precise external-source reconstruction, pass an explicit repository
identity and `source.sha`. Preserve `source_ref`, provenance `sha`,
`ingest_path`, compiler and feature versions, the code-to-DATAWAVE receipt, and
the reported Repo KG state. If SHA is omitted, compose may resolve the current
stored or checkout revision; that is not immutable pinned-source proof.

The pipeline is conservative by design:

- a feature slice carries `unknowns`, including missing matched symbols or
  linked tests;
- behavior IR carries evidence, APIs, models, operations, effects, errors,
  invariants, and portability hazards;
- target planning opens an obligation that generated output is a scaffold and
  must be implemented and bound into the destination project;
- emitted patch sets preserve `unresolved_obligations` and normally remain
  `needs_review`;
- `reverseEngineerValidate` / `reverse_engineer_validate` creates validation
  receipts with status `not_run`; it does not apply the patch or run commands;
- `reverseEngineerPort` / `reverse_engineer_port` returns the composed
  artifacts. It does not prove structural, semantic, live, or end-to-end
  parity.

Never erase unknowns or open obligations to make a reconstruction look
complete. Apply the patch in the target checkout, run the declared commands and
real parity oracles, then record those results through the verification
capability.

## Honest gaps

The following remain substrate work, not plugin aliases:

- GraphQL bridges for DATAWAVE and resolve;
- real structural and semantic parity checks;
- a pinned end-to-end reconstruction oracle;
- a stable dynamic reconstruction capability.
