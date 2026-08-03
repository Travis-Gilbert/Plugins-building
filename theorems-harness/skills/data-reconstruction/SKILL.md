---
name: data-reconstruction
description: "Use when an agent must query Data records or instant-KG views, run flat-only DATAWAVE or entity resolution, or compose source reconstruction while preserving source pins, receipts, unknowns, and unresolved obligations."
---

# Data and reconstruction

Generated surface map: [capability catalog](./CAPABILITIES.generated.md).

Read `../../references/DATA_RECONSTRUCTION_CAPABILITY.md` before using this
family. The projections differ; do not translate a flat-only action into an
invented GraphQL or dynamic tool.

## Route

1. Introspect GraphQL when it is available.
2. For records and saved views, use `dataSchema`, `dataRecords`, `dataRecord`,
   `dataLinks`, `dataQuery`, `dataRetrieve`, `dataViews`, `dataView`, or the
   `upsertDataView` mutation. Use `query_data` only for compatibility or
   envelope diagnosis.
3. For immutable source manifests and publication lineage, use GraphQL
   `dataRegistry` / `dataRegistries` / `publishDataRegistry` or flat
   `data_registry_get` / `data_registry_list` / `data_registry_publish`.
   Publication requires admitted write authority; conflicts and unknown
   obligations remain explicit rather than replacing the first manifest.
4. For the instant KG, use the `harnessKg*` GraphQL reads or their exact
   `harness_kg_*` flat counterparts: for example, `harnessKgStatus` maps to
   `harness_kg_status`.
5. Use flat `datawave_ingest`, `resolve_ingest`, `resolve_entities`,
   `resolve_explain`, and `memory_dedup_report` only when the advertised flat
   tools exist. They have no GraphQL bridge.
6. For source reconstruction, prefer the seven `reverseEngineer*` mutations;
   use the exact `reverse_engineer_*` flat tools for compatibility. Use
   `reconstruct`, `reconstruct_binary`, or `datawave_ingest` only for their
   broader flat-only modes.

The source pipeline begins at `reverseEngineerCompose` /
`reverse_engineer_compose`. `reverseEngineerValidate` /
`reverse_engineer_validate` only attaches planned validation receipts; it does
not run the target commands.

## Reconstruction workflow

1. Bind the repository identity and, when exact source parity matters, an
   explicit `source.sha`.
2. Compose, then inspect provenance, `source_ref`, Repo KG state, receipts,
   drift, and obligations.
3. Slice the requested feature and retain `unknowns`.
4. Compile behavior IR and a target plan. Do not discard portability hazards or
   the scaffold obligation.
5. Emit a patch set and inspect `unresolved_obligations` and status.
6. Treat validate-stage `not_run` receipts as commands still owed. Apply the
   patch in the destination checkout and run real structural, semantic, and
   behavioral oracles there.
7. Record only the proof actually obtained through the verification surface.

`reverseEngineerPort` is a convenient composition, not proof of a finished
port. An omitted SHA may bind current state and is not immutable source-manifest
lineage. Publish the explicit source manifest first when durable identity is
required. There is no stable dynamic reconstruction affordance,
resolve/DATAWAVE GraphQL bridge, real structural-plus-semantic parity executor,
or pinned end-to-end parity oracle yet.
