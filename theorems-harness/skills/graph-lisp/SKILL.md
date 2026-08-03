---
name: graph-lisp
description: "Use when an agent needs bounded pure Graph Lisp read, eval, diff, or explain through the dynamic gateway or GraphQL, including fuel, permission, graph-version, receipt, and effect-isolation semantics."
---

# Graph Lisp agent capability

Generated surface map: [capability catalog](./CAPABILITIES.generated.md).

Read `../../references/GRAPH_LISP_CAPABILITY.md` before claiming Graph Lisp can
be invoked by an agent session.

## Workflow

1. Prefer GraphQL `graphLispRead`, `graphLispEval`, `graphLispDiff`, or
   `graphLispExplain` when the typed schema is available.
2. For dynamic routing, use `tool_search` -> `describe` -> `invoke` with the
   exact affordance ids `graph-lisp.read`, `graph-lisp.eval`,
   `graph-lisp.diff`, and `graph-lisp.explain`.
   These are the remote projections of the pure `read`, `eval`, `diff`, and
   `explain` operations.
3. In Rust repository work, the source-owned kernel remains
   `rustyred_thg_graph_lisp::execute_capability` with a `CapabilityRequest`,
   nonblank graph version, `CapabilityLimits`, and `CapabilityPolicy`.
4. Keep typed results and the full `CapabilityReceipt`. Remote calls bind the
   admitted principal and the backend's committed graph version rather than
   trusting caller identity or a caller-supplied graph version.
5. Treat source-byte, node, fuel, permission, read, and evaluation outcomes as
   typed refusals/failures. Preserve deterministic anchors and replay bytes.
6. Never execute effects through `dynamic_call`. A grant still returns
   `external_executor_required`; effectful capabilities need their own admitted
   executor.
7. Do not invent flat `graph_lisp_*` tools or expose `dynamic_call`. The remote
   projections are the four GraphQL queries and the four dynamic affordances
   above. Native discovery synthesizes these read-only affordances without a
   graph write, including for permanently read-only unseeded tenants.
