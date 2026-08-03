<!-- GENERATED: scripts/generate_harness_capability_projections.py -->
# Data and reconstruction capability catalog

Data, instant KG, resolution, DATAWAVE, and staged reconstruction preserve provenance and unresolved obligations.

Plugin version: `0.10.0`. Source server version: `0.5.0`.
Source catalog SHA-256: `feb39dae1c91bf89c5050323c4922f9fbbc5092b6ac5f85fffa34396a173701b`.

| Capability | Surface | Guidance | Maturity | Live status | Schema/source | Canonical descriptor |
|---|---|---|---|---|---|---|
| `data_registry_get` | flat_mcp | read one immutable source manifest and publication receipt | stable | source-advertised; live-unverified | `tools/list:data_registry_get` | — |
| `data_registry_list` | flat_mcp | bounded source-registry listing | stable | source-advertised; live-unverified | `tools/list:data_registry_list` | — |
| `data_registry_publish` | flat_mcp | publish an admitted immutable source manifest | stable | source-advertised; live-unverified | `tools/list:data_registry_publish` | — |
| `datawave_ingest` | flat_mcp | flat-only DATAWAVE ingestion | beta | source-advertised; live-unverified | `tools/list:datawave_ingest` | — |
| `query_data` | flat_mcp | flat Data compatibility | stable | source-advertised; live-unverified | `tools/list:query_data` | — |
| `reconstruct_binary` | flat_mcp | flat-only binary reconstruction | beta | source-advertised; live-unverified | `tools/list:reconstruct_binary` | — |
| `resolve_ingest` | flat_mcp | flat-only entity resolution | stable | source-advertised; live-unverified | `tools/list:resolve_ingest` | — |
| `Mutation.publishDataRegistry` | graphql | publish an admitted immutable source manifest | stable | source-advertised; live-unverified | `graphql_introspect:Mutation.publishDataRegistry` | — |
| `Mutation.reverseEngineerCompose` | graphql | typed staged reconstruction | beta | source-advertised; live-unverified | `graphql_introspect:Mutation.reverseEngineerCompose` | — |
| `Query.dataQuery` | graphql | preferred typed Data query | stable | source-advertised; live-unverified | `graphql_introspect:Query.dataQuery` | — |
| `Query.dataRegistries` | graphql | bounded typed source-registry listing | stable | source-advertised; live-unverified | `graphql_introspect:Query.dataRegistries` | — |
| `Query.dataRegistry` | graphql | read one immutable source manifest and its publication lineage | stable | source-advertised; live-unverified | `graphql_introspect:Query.dataRegistry` | — |
| `Query.harnessKgSearch` | graphql | preferred typed instant-KG search | stable | source-advertised; live-unverified | `graphql_introspect:Query.harnessKgSearch` | — |

Behavioral contract: `references/DATA_RECONSTRUCTION_CAPABILITY.md` in the source plugin.
Live status is an explicit claim, not an inference from implementation presence.
