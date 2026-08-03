<!-- GENERATED: scripts/generate_harness_capability_projections.py -->
# Graph Lisp capability catalog

Bounded pure Graph Lisp read, eval, diff, and explain share admitted dynamic and GraphQL projections with deterministic receipts.

Plugin version: `0.10.0`. Source server version: `0.5.0`.
Source catalog SHA-256: `feb39dae1c91bf89c5050323c4922f9fbbc5092b6ac5f85fffa34396a173701b`.

| Capability | Surface | Guidance | Maturity | Live status | Schema/source | Canonical descriptor |
|---|---|---|---|---|---|---|
| `graph-lisp.diff` | dynamic | discover and invoke addressed expression diff | stable dynamic | registry-declared; live-unverified | `describe:graph-lisp.diff` | — |
| `graph-lisp.eval` | dynamic | discover and invoke fuel-bounded pure evaluation | stable dynamic | registry-declared; live-unverified | `describe:graph-lisp.eval` | — |
| `graph-lisp.explain` | dynamic | discover and invoke pure expression explanation | stable dynamic | registry-declared; live-unverified | `describe:graph-lisp.explain` | — |
| `graph-lisp.read` | dynamic | discover and invoke the bounded pure reader | stable dynamic | registry-declared; live-unverified | `describe:graph-lisp.read` | — |
| `Query.graphLispDiff` | graphql | typed addressed expression diff | stable | source-advertised; live-unverified | `graphql_introspect:Query.graphLispDiff` | — |
| `Query.graphLispEval` | graphql | typed fuel-bounded pure evaluation | stable | source-advertised; live-unverified | `graphql_introspect:Query.graphLispEval` | — |
| `Query.graphLispExplain` | graphql | typed pure expression explanation | stable | source-advertised; live-unverified | `graphql_introspect:Query.graphLispExplain` | — |
| `Query.graphLispRead` | graphql | typed bounded pure reader | stable | source-advertised; live-unverified | `graphql_introspect:Query.graphLispRead` | — |
| `rustyred_thg_graph_lisp::execute_capability` | rust | source-owned pure execution kernel | stable source | projected through dynamic and GraphQL adapters | `rustyred-thg-graph-lisp` | — |

Behavioral contract: `references/GRAPH_LISP_CAPABILITY.md` in the source plugin.
Live status is an explicit claim, not an inference from implementation presence.
