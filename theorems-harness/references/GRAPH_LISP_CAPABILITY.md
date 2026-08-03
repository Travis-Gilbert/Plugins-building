# Graph Lisp Agent Capability

Graph Lisp exposes one bounded, deterministic, pure capability through a Rust
kernel plus matching dynamic and GraphQL adapters. The adapters share the
kernel's result and receipt semantics; they do not create a second evaluator.

## Agent-callable projections

| Operation | GraphQL | Dynamic affordance |
|---|---|---|
| Read | `graphLispRead` | `graph-lisp.read` |
| Evaluate | `graphLispEval` | `graph-lisp.eval` |
| Diff | `graphLispDiff` | `graph-lisp.diff` |
| Explain | `graphLispExplain` | `graph-lisp.explain` |

Use `tool_search` -> `describe` -> `invoke` for the dynamic projection. The
Graph Lisp connector advertises only these four operations and a read-only
writeback policy. GraphQL returns typed values, failures, identity binding,
graph version, and the same content-addressed receipt fields.

## Rust capability surface

`execute_capability(request, graph_version, limits, policy)` accepts these
`CapabilityRequest` operations:

| Operation | Input | Result |
|---|---|---|
| `read` | Source text | Content-addressed root, normalized readable source, and addressed expression nodes. |
| `eval` | Source text and fuel | Root plus a `TypedValue`. |
| `diff` | Before and after source | Before/after roots and added/removed expression ids. |
| `explain` | Source text | Root, normalized source, node count, free symbols, collection-node count, and `evaluator_is_pure`. |
| `dynamic_call` | Capability name and argument anchor | Never executes in this crate; even a granted request refuses with `external_executor_required`. |

Typed values are nil, boolean, integer, string, keyword, symbol, list, vector,
map, or function. The reader alpha-normalizes lexical binders before hashing,
hash-conses identical subexpressions, and limits structural diffs to the changed
spine.

## Limits and permission

`CapabilityLimits::default()` applies:

- 64 KiB maximum source bytes;
- 10,000 maximum expression nodes;
- 1,000,000 maximum requested evaluation fuel.

`CapabilityPolicy::pure()` permits only read, eval, diff, and explain.
`CapabilityPolicy::deny_all()` refuses all operations. A dynamic grant proves
only that an external effectful executor may receive the request; the pure
crate still refuses to perform the effect.

The crate-local API requires a nonblank caller-provided `graph_version` and
binds it into the receipt. The remote adapters instead derive the version from
the backend's committed graph state and overwrite identity with the admitted
principal, actor, and binding. The strict-AOF multi-writer oracle proves that
remote receipts anchor to committed versions, survive reopen, replay
byte-stably at a historical anchor, and refuse stale version assumptions.

## Receipts and refusals

Every success returns a `CapabilityExecution` with a typed result and
`CapabilityReceipt`. Every refusal or failure returns `CapabilityFailure` with
the same receipt shape. Preserve:

- receipt version and content-addressed `receipt_id`;
- operation and caller-provided graph version;
- deterministic `input_anchor` and optional `outcome_anchor`;
- status `succeeded`, `refused`, or `failed`;
- error code;
- fuel limit and fuel used.

Error codes are `invalid_graph_version`, `input_too_large`,
`node_limit_exceeded`, `fuel_limit_exceeded`, `permission_denied`,
`external_executor_required`, `read_failure`, `fuel_exhausted`, and
`eval_failure`. `replay_bytes()` is byte-stable for an identical execution or
failure.

## Current proof and exposure boundary

Focused crate tests prove direct read/eval/diff/explain parity, typed values,
bounded fuel and input refusals, permission refusal, effect isolation, and
byte-stable replay. The public parity fixture proves dynamic/GraphQL receipt
identity and deterministic refusal, and the durable oracle proves committed
graph-version anchoring.

Native discovery synthesizes the four Graph Lisp affordances without mutating
the graph, so a permanently read-only unseeded tenant can complete
`tool_search` -> `describe` -> pure `invoke`. The focused public oracle proves
that path alongside the persisted-catalog path. Do not invent flat
`graph_lisp_*` tools, and route effectful work only through separately
registered, permissioned capabilities; `dynamic_call` remains unexposed.
