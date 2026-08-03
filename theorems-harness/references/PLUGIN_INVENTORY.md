# Plugin Inventory

Inventory generated for the Theorem's Harness upgrade.

The public model is now adaptive: `/harness` is the session/task opt-in and the
agent selects capability mixes as the work evolves. Utility commands remain for
narrow entrypoints, but they are not separate products.

## Skills

| Skill | Public role | Orchestrate role | Compatibility |
|---|---|---|---|
| `theorems-harness` | Default adaptive command | Owns observe, route, plan, coordinate, delegate, execute, validate, report, learn | Canonical |
| `practice-system` | Ambient practice graph | Binds planning, execution, verification, review, and run-to-run learning to the active Harness run | Canonical |
| `harness-coordinate` | Public utility command | Teaches room/intent reads, typed coordination records, presence, mentions, durable streams, and handoff without retired aliases | Keep available |
| `peer-review` | Public and agent-triggerable command | Requests cross-frontier-model review before commit, PR, or launch-ready reporting | Keep available |
| `research` | Public utility command | Runs fractal expansion, gap-frontier discovery, and code-symbol discovery | Keep available |
| `encode` | Public and agent-triggerable command | Records feedback, solutions, and postmortems | Keep available |
| `replay-last-run` | Public audit utility | Selects the latest eligible run, deterministically replays it, and returns typed integrity evidence | Canonical |
| `identity-bindings` | Focused capability workflow | Resolves the admitted principal and typed binding receipt without caller-supplied identity claims | Canonical |
| `context-management` | Focused capability workflow | Teaches scoped leases, compile/reuse, explicit invalidation, generations, dispositions, and the current hook boundary | Canonical |
| `commitments-policy` | Focused capability workflow | Separates remote standing decisions and policy receipts from the Rust-only canonical typed claim, commitment, and constitution seams | Canonical |
| `graph-lisp` | Focused capability workflow | Teaches admitted dynamic and GraphQL bounded read/eval/diff/explain, deterministic receipts, and the unexposed effect boundary | Canonical |
| `data-reconstruction` | Focused capability workflow | Routes typed Data, durable source manifests, instant-KG reads, flat-only DATAWAVE/resolve, and obligation-preserving reconstruction | Canonical |
| `learning-evolution` | Focused capability workflow | Separates callable outcome, memory, practice, and programmable-graph validation seams from Rust-only GEPA, ReasoningBank, and theorem-evolve lifecycle code | Canonical |
| `agent-interop` | Focused capability workflow | Teaches admitted composed-agent turns, durable Head Calls, Rust-only A2A, and the server ACP WebSocket with live-provider boundaries | Canonical |
| `coordination-operations` | Focused capability workflow | Separates rooms/records, task-reference rooms, streams, jobs, work graphs, session dispatch, and service operations | Canonical |
| `graph-storage` | Focused capability workflow | Routes GraphQL and flat graph primitives, admin mutation receipts, caller-carried versions, resources, and storage readiness | Canonical |
| `agent-contracts` | Focused capability workflow | Interprets MCP/GraphQL error layers, family-specific pagination, result fetching, idempotency, budgets, and receipts | Canonical |
| `solvers` | Focused capability workflow | Discovers, describes, and invokes stable `constraint.check` and `constraint.optimize` affordances and interprets typed proof receipts | Canonical |
| `programmable-wasm` | Focused capability workflow | Separates installed app exports (`wasm_plugin:<plugin_id>.<export>`) from the Rust-only durable lifecycle | Canonical |
| `verified-cognition` | Focused composition workflow | Separates proposals from proof while composing only real solver, reconstruction, verification, and Plan surfaces; names absent workflow orchestration honestly | Canonical |
| `writing-engineering` | Public writing utility | Applies Writing Engineering with the 1918 Elements rules integrated into one ruleset and receipt | Canonical |
| `theorize` | Internal phase skill | Internal `theorize` mode | Keep available |
| `planning-theorem` | Internal phase skill | Internal `plan` mode | Keep available |
| `execute` | Compatibility command / internal capability | Bounded implementation loop with validation and rerouting | Keep available |

## Companion plugins (routing targets)

Plugins that Orchestrate routes to but does not own. Listed here so the
plugin-router agent knows the available delegation surfaces.

| Plugin | Version | Trigger intent | Owns |
|---|---|---|---|
| `ui-design-pro` | 1.2.0+ | "design this", "lay this out", "wireframe", "prototype", "build me a Y component", "how should this look" | Design planning, component selection from 39-item curated catalog + 19 vendored design-system repos (Radix, shadcn, Tailwind, ant-design, carbon, magicui, etc.), applied design theory (10 references) |

When routing design work, prefer `ui-design-pro` over hand-rolling. The
plugin's `design-pro` skill (v1.2.0 replacement of `design-theory`)
enforces a components-first protocol: catalog scan → vendored libraries
→ hand-rolled only as last resort with explicit justification.

## Profiles

Registry-level operating policies. Not skills, not slash commands. They
change run policy before the agent thinks. See `PROFILES.md` for the
registry contract.

| Profile | Kind | Default | Priority | Spec |
|---|---|---|---|---|
| `engineers-mindset` | `orchestration_profile` | enabled | high | `ENGINEERS_MINDSET.md` |
| `concise-action` | `output_profile` | enabled | high | `CONCISE_ACTION.md` |

Selected profiles (e.g. `developer-core`, `researcher-core`) are chosen
per task by the orchestrate backend and carried in
`decision.selected_profile_id`. They are not registry-static and are not
listed here.

## Agents

| Agent | Role |
|---|---|
| `checklist-manifest` | Builds the codebase-grounded checklist manifest before work and reconciles the same checklist at completion. |
| `codex-sdk-harness-product` | Grounds SDK/database harness and product-client claims in shipped code; read-only context, not implementation ownership. |
| `orchestrate-planner` | Builds production plans and stable checklists. |
| `plugin-router` | Selects capability mixes, hidden plugins/skills, profiles, validators, and exposure recommendations. |
| `context-artifact-specialist` | Defines Context Artifact, Capsule, Brief, and trust-boundary requirements. |
| `action-rail-specialist` | Produces safe next actions with validators and approval gates. |
| `validator-reporter` | Chooses checks and reconciles validation evidence. |
| `epistemic-graphrag-specialist` | Gathers GraphRAG/GNN-RAG evidence context, retrieval operators, and trace needs. |
| `federation-learning-recorder` | Prepares local learning and safe structural federation candidates. |
| `redis-harness-operator` | Provides Redis harness guardrails for cache/run/event boundaries and fallback behavior. |
| `redis-product-safety` | Provides tenant THG product safety checks for auth, Redis key isolation, and RESP gates. |

## Commands Exposed

Default adaptive product command:

- `/harness`

Utility commands:

- `/coordinate`
- `/peer-review`
- `/research`
- `/encode`
- `/compute_code`
- `/replay-last-run`
- `/writing-engineering`

`/compute_code` teaches the complete code capability: GraphQL-first
ingest/reindex/status/search/context/explain/spec/drift/features/obligations,
with the consolidated flat MCP fallbacks documented in `CODE_CAPABILITY.md`.

Harness memory teaching is GraphQL-first across `memory`, `memoryDoc`, nested
`links`/`related`, `memoryArchive`, `rememberMemory`, `reviseMemory`,
`forgetMemory`, and `createHandoff`. It preserves ranked episode provenance and
keeps actor-memory/Data API tools, retro-import, opt-out, deduplication,
reentrancy, and practice promotion in their real boundaries. See
`MEMORY_CAPABILITY.md`.

Canonical verification teaching covers GraphQL and flat receipt record, read,
explain, allocation, and calibration reliability surfaces. It preserves
support/attack lineage, graph-version freshness, authenticated actor/binding
admission, self-reported head/model limits, and the boundary between reliability
tiers and authorization. See `VERIFICATION_CAPABILITY.md`.

Identity and binding teaching prefers typed GraphQL `identityBindingStatus` and
`identityBindingExplain`, with flat `identity_binding_status` and
`identity_binding_explain` for compatibility. The queries accept no identity
arguments; admitted-session authority, selection rules, receipt fields, and
the live proof gaps are in `IDENTITY_CAPABILITY.md`.

Context teaching maps GraphQL `contextStatus`, `contextExplain`,
`refreshContext`, and `invalidateContext` to flat `context_status`,
`context_explain`, `harness_prepare`, and `context_invalidate`. It preserves
lease decisions, included/excluded spans, stale/evicted generations, and the
fact that current PostToolUse/PreCompact hooks do not advance the context
epoch. See `CONTEXT_CAPABILITY.md`.

Commitments and policy teaching uses GraphQL `writeCoordinationRecord` and
`recordClaim` plus flat `coordination_record`, `commitment_retract`,
`commitment_supersede`, and `commitment_check` for their current coordination
contracts. It keeps the canonical Rust `assert_typed_claim`, typed commitment,
and structured constitution-refusal seams explicitly non-remote. See
`COMMITMENTS_POLICY_CAPABILITY.md`.

Graph Lisp teaching covers the source `execute_capability` kernel plus dynamic
`graph-lisp.read/eval/diff/explain` and typed GraphQL `graphLisp*` projections.
Granted effects still refuse with `external_executor_required`, and
`dynamic_call` remains unexposed. See `GRAPH_LISP_CAPABILITY.md`.

Data and reconstruction teaching uses typed GraphQL `dataSchema` through
`upsertDataView`, the exact `harnessKg*` reads, and the seven
`reverseEngineerCompose` through `reverseEngineerPort` mutations where those
projections exist. It preserves flat-only `datawave_ingest`, `resolve_ingest`,
`resolve_entities`, `resolve_explain`, `memory_dedup_report`, `reconstruct`, and
`reconstruct_binary`, plus source pins, receipts, unknowns, and unresolved
obligations. Persistent DataRegistry teaching maps `dataRegistry`,
`dataRegistries`, and `publishDataRegistry` to flat `data_registry_get`,
`data_registry_list`, and `data_registry_publish`. See
`DATA_RECONSTRUCTION_CAPABILITY.md`.

Learning and evolution teaching uses canonical verification/calibration,
ordinary memory/run outcomes, practice learning, and flat `programmable_graph`
proposal validation where those remote seams exist. GEPA trainsets/gates,
ReasoningBank entry points, and `theorem-evolve` evaluation/promotion remain
Rust-only and cannot be presented as remote lifecycle actions. See
`LEARNING_EVOLUTION_CAPABILITY.md`.

Agent interoperability teaching uses flat `composed_agent_run`, durable
`stream_publish` Head Calls, and the authenticated Head Call and ACP WebSocket
routes. A2A card registration/invocation remains crate-level, and configured
providers are not described as live without invocation receipts. See
`AGENT_INTEROP_CAPABILITY.md`.

Coordination and operations teaching maps typed and flat room/record/stream
surfaces, GraphQL-only task-reference rooms, derived-state jobs, work graphs,
GitHub Actions session dispatch, and HTTP readiness/discovery without treating
them as one task API. See `COORDINATION_OPERATIONS_CAPABILITY.md`.

Graph and storage teaching prefers typed GraphQL where covered, preserves
flat-only query/version diagnostics, enforces administrative mutation receipts,
and distinguishes caller-carried graph repositories from unprojected storage
internals. See `GRAPH_STORAGE_CAPABILITY.md`.

Agent-contract teaching preserves the actual JSON-RPC, tool-level, GraphQL, and
domain error layers; separate cursors and fetch offsets; and family-specific
receipts instead of inventing a universal envelope. See
`AGENT_CONTRACTS_CAPABILITY.md`.

Stable solver teaching uses only the dynamic `tool_search` -> `describe` ->
`invoke` sequence for `constraint.check` and `constraint.optimize`, preserving
budgets, provider provenance, refusal, and proof eligibility. See
`SOLVER_CAPABILITY.md`.

Programmable WASM teaching exposes installed app exports through the same
dynamic gateway while keeping publish, promote, inspect, selected invocation,
receipt lookup, and rollback at the current Rust substrate boundary. See
`PROGRAMMABLE_WASM_CAPABILITY.md`.

Verified cognition teaching is a disciplined composition of
`constraint.check`, reconstruction stages, canonical verification receipts,
and the Plan lifecycle. The planned verified-decision, consistency,
reconstruction, repair, and voice orchestrators are not callable surfaces. See
`VERIFIED_COGNITION_CAPABILITY.md`.

Internal capability language:

The machine-checked compact projection is
`CAPABILITY_CATALOG.generated.md`; removed and compatibility-only names are in
`COMPATIBILITY.generated.md`. Both are regenerated from `capabilities/` and
must not be edited by hand.

- `theorize` -> `/harness mode=theorize`
- `planning-theorem` -> `/harness mode=plan`
- `execute` -> `/harness mode=execute`

## Internal Modes

- observe
- route
- theorize
- plan
- delegate
- compile_context
- action_rail
- execute
- validate
- report
- remember
- federation_signal

## References

- `ARTIFACT_SCHEMAS.md`
- `AGENT_CONTRACTS_CAPABILITY.md`
- `AGENT_INTEROP_CAPABILITY.md`
- `BRIEF_TEMPLATE.md`
- `CHECKLIST_MANIFESTO.md`
- `CODE_CAPABILITY.md`
- `COMMITMENTS_POLICY_CAPABILITY.md`
- `CONCISE_ACTION.md`
- `CONTEXT_CAPABILITY.md`
- `COORDINATION_OPERATIONS_CAPABILITY.md`
- `DATA_RECONSTRUCTION_CAPABILITY.md`
- `ENGINEERS_MINDSET.md`
- `EPISTEMIC_PRIMITIVES.md`
- `GRAPH_LISP_CAPABILITY.md`
- `GRAPH_STORAGE_CAPABILITY.md`
- `HOST_REPO_OPT_IN.md`
- `IDENTITY_CAPABILITY.md`
- `LEARNINGS.md`
- `LEARNING_EVOLUTION_CAPABILITY.md`
- `MEMORY_CAPABILITY.md`
- `ORCHESTRATE_REPORTING.md`
- `PLAN_TEMPLATE.md`
- `PLANNED-CAPABILITY-PLUGIN-IDEAS.md`
- `PRODUCTION_GATES.md`
- `PROGRAMMABLE_WASM_CAPABILITY.md`
- `PROFILES.md`
- `REFS_AUDIT.md`
- `REFS_MANIFEST.md`
- `REPORTING.md`
- `ROUTING.md`
- `SDK_DATABASE_HARNESS.md`
- `SETTINGS.md`
- `SOLVER_CAPABILITY.md`
- `UI_VISUAL_PROJECT_GATES.md`
- `VERIFICATION_CAPABILITY.md`
- `VERIFIED_COGNITION_CAPABILITY.md`

## Compatibility Risks

- Host environments may retain an installed-cache copy of removed skills until
  the plugin is refreshed. Source and generated manifests intentionally omit
  every retired interface, and none has an alias.
- Redis/harness writeback is environment-sensitive. Orchestrate must report
  writeback as proven or deferred per run.
- The default harness SDK client and tenant-scoped THG product client remain
  separate surfaces and must not be merged in docs or reports.
