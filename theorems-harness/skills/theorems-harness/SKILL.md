---
name: theorems-harness
description: Theorem's Harness default plugin skill. Use when the user invokes /harness or asks for grounded planning, implementation, debugging, review, context preparation, validation, reporting, cross-agent coordination, typed memory, encode, run lifecycle, replay, fractal search, code search, or harness-backed agent work.
---

# Theorem's Harness

Theorem's Harness is the public product layer for grounded agent work. The SDK
is plumbing, GraphQL MCP is the preferred tool bus, hooks provide ambient
session support, and skills/commands are the behavior contract that agents
actually inhabit.

When `graphql_query`, `graphql_mutate`, and `graphql_introspect` are available,
use them as the primary Harness MCP API. Start with `graphql_introspect` when the
schema is not already in context, then use GraphQL for memory, coordination,
jobs, graph, code, and run surfaces. Use legacy flat tools only when GraphQL is
unavailable, the session is intentionally on a local/dev flat-tool server, or
you are diagnosing flat-tool compatibility.

Host UIs may display Harness tools with plugin-qualified labels such as
`Theorem's Harness Recall`, `theorems-harness recall`, or
`mcp__codex_apps__theorems_harness._recall`. Treat those labels as
routing/display names for the native MCP verbs (`recall`, `remember`, `encode`),
not as a different memory system. In user-facing reports, prefer product
language like "Harness recall", "Harness encode", or "Harness memory" unless the
wire-level identifier matters.

The core change: `/harness` is not a request to force one narrow mode. It is the
operator saying "use the harness for this session or task." After that, the
agent chooses the most useful capability mix, revisits that choice at
checkpoints, and keeps moving unless a real blocker requires user input.

## Session Contract

When the user invokes `/harness`, "Theorem's Harness", or an equivalent phrase:

1. Treat it as consent to use harness abilities for the active task.
2. Resolve the current task from the user's words and live repo state.
3. Select the first capability mix by applying the routing rules below plus the
   injected Product Packet (see Liveness). For anything outside the taught
   families, discover it at runtime: `tool_search` -> `describe` -> `invoke`.
4. Work through short cycles: observe, choose, act, check, and decide whether to
   continue, pivot, coordinate, validate, remember, or report.
5. Keep the harness visible only where it helps the user trust the work. Do not
   narrate every internal switch.

The command may accept `mode=plan`, `mode=execute`, or similar hints, but hints
are not handcuffs. Honor the user's explicit intent, then add supporting
capabilities when the work needs them.

## Capability Palette

Use these as abilities inside one run, not as competing products:

| Capability | Use it when |
|---|---|
| `observe` | Ground the task in repo state, tool state, runtime state, and current context. |
| `theorize` | Several real approaches exist and a short option pass will avoid churn. |
| `plan` | The task needs stable acceptance criteria, a checklist, or multi-session memory. |
| `execute` | Files must change, tests must run, bugs must be fixed, or a slice must ship. |
| `diagnose` | A failure, regression, flaky test, deploy issue, or runtime surprise appears. |
| `coordinate` | Claude Code, Codex, Claude.ai, or another agent may overlap the work. |
| `ambition` | A build, plan, or handoff could be underscoped relative to what was asked. |
| `identity` | The admitted principal, project selection, actor, binding, active heads, scopes, budget, or provenance must be inspected. |
| `compile_context` | Context status, lease reuse, explicit compilation/invalidation, generations, or span disposition matters. |
| `governance` | A standing decision, structured claim, typed witness, constitution refusal, or policy receipt must be created or interpreted. |
| `graph_lisp` | Repository work needs bounded pure Graph Lisp read/eval/diff/explain or its receipt/refusal contract. |
| `data_reconstruction` | Typed Data or instant-KG reads, flat DATAWAVE/resolve, or receipt- and obligation-preserving source reconstruction is needed. |
| `learning_evolution` | Outcomes, calibration, GEPA, ReasoningBank, or evolution work must distinguish callable evidence seams from Rust-only lifecycle APIs. |
| `agent_interop` | A composed-agent turn, durable Head Call, A2A boundary, ACP session, or live provider claim must be routed exactly. |
| `coordination_operations` | Rooms, durable streams, dispatch jobs, work graphs, spawning, or service readiness must use their real distinct state machines. |
| `graph_storage` | Graph reads, algorithms, administrative mutations, version values, or storage readiness must be routed without exposing internals. |
| `agent_contracts` | A result crosses MCP, GraphQL, HTTP, pagination, truncation, error, idempotency, or receipt boundaries. |
| `research` | Evidence, graph search, code search, or external/current reality is needed. |
| `solve` | A bounded constraint check or pack optimization needs typed provider and proof receipts. |
| `verified_cognition` | A decision, consistency, reconstruction, or repair claim must compose proposals and real proof surfaces without inventing a workflow. |
| `programmable_wasm` | An installed app export must be invoked, or a durable WASM lifecycle boundary must be inspected honestly. |
| `validate` | A claim needs tests, screenshots, deploy proof, replay, or runtime evidence. |
| `peer_review` | A risky diff, multi-agent edit, commit, PR, or launch-ready claim is near. |
| `remember` | The session produced a reusable lesson, decision, postmortem, or correction. |
| `report` | The user needs a concise, truthful closeout with done/partial/blocked state. |

## Routing Heuristics

- If the user asks to coordinate, message, ping, hand off, or work with another
  agent, start with `coordinate`, then return to the main work.
- If the user asks to implement, fix, ship, simplify, or run tests, start with
  `execute`; add `diagnose` when a failure is not yet understood.
- If the user asks for a plan, spec, migration, checklist, or multi-session
  strategy, start with `plan`; allow a bounded execution handoff only when the
  first slice is obvious or requested.
- Plan-shaped work routes through the durable plan substrate: `plan create` is
  the canonical act. Execute each task through `claim` -> `patch_proposed`
  (with the exact `patch_digest`) ->
  `spawn_verify` -> `submit_verify` -> `prove` -> `done`, with the verify
  sibling assigned to a reviewer distinct from the author and claimant. Plans
  are referenced by id/digest — never re-encoded into coordination records,
  messages, or reflections.
- If the user asks for research, evidence, graph search, code discovery, or
  current external facts, start with `research` or `compile_context`.
- If identity, project selection, actor, binding, active heads, scopes, or
  budget authority matters, load `identity-bindings`. Use only
  `identityBindingStatus` / `identityBindingExplain` or the flat
  `identity_binding_status` / `identity_binding_explain` compatibility tools;
  pass no identity arguments.
- If context state, lease, compilation, invalidation, generation, or span
  disposition matters, load `context-management`. Use `harness_prepare` or
  GraphQL `refreshContext` for preparation and `context_invalidate` or
  `invalidateContext` for an epoch advance. Do not claim the current hooks
  perform that invalidation.
- If a standing decision, claim conflict, constitution rule, or policy receipt
  matters, load `commitments-policy`. Use GraphQL `writeCoordinationRecord` /
  `recordClaim` and the real flat lifecycle including `commitment_check` for
  remote coordination; reserve `assert_typed_claim` and the canonical typed
  lifecycle for Rust repository work until it is projected.
- If Graph Lisp matters, load `graph-lisp`. Prefer typed `graphLisp*` queries or
  the exact dynamic `graph-lisp.read/eval/diff/explain` affordances. The Rust
  kernel remains `execute_capability`; effect requests refuse with
  `external_executor_required`.
- If Data, instant KG, DATAWAVE, resolve, or source reconstruction matters,
  load `data-reconstruction`. Use `dataRegistry`, `dataRegistries`, and
  `publishDataRegistry` for durable source manifests. Prefer typed GraphQL
  where it exists; keep
  `resolve_ingest`, `resolve_entities`, `resolve_explain`, `datawave_ingest`,
  `reconstruct`, and `reconstruct_binary` flat-only. Preserve source SHAs,
  receipts, unknowns, unresolved obligations, and validation `not_run` state.
- If learning, GEPA, ReasoningBank, or candidate evolution matters, load
  `learning-evolution`. Use canonical outcome/calibration and memory evidence;
  treat `programmable_graph` evolve as proposal validation and keep the GEPA
  and `theorem-evolve` lifecycle Rust-only.
- If composed-agent invocation, Head Calls, A2A, ACP, or provider execution
  matters, load `agent-interop`. Use `composed_agent_run` and durable
  `stream_publish` / `stream_read` / `stream_ack` where callable, preserve
  admitted identity and budget, and require receipts before claiming live
  execution.
- If coordination, durable streams, jobs, work graphs, spawning, readiness, or
  catalog identity matters, load `coordination-operations`. Keep room records,
  stream cursors, job state, and operational probes distinct.
- If graph reads, algorithms, administrative graph writes, graph versions, or
  storage mode matters, load `graph-storage`. Prefer typed GraphQL, preserve
  mutation receipts, and keep caller-carried snapshots separate from live
  graph state.
- If an error, page, truncated result, retry, budget, or receipt crosses
  capability families, load `agent-contracts`. Inspect every protocol/domain
  layer and never synthesize a universal result contract.
- If the user asks for satisfiability, constraint checking, or bounded pack
  optimization, load `solvers` and use only `constraint.check` or
  `constraint.optimize` through the dynamic gateway.
- If the user asks for verified decision, consistency, reconstruction, repair,
  or voice, load `verified-cognition`. Compose only real solver,
  reconstruction, verification, and Plan surfaces; report the missing workflow
  orchestrator or voice surface instead of inventing one.
- If the user asks about programmable WASM, load `programmable-wasm`. Invoke an
  installed export only through `wasm_plugin:<plugin_id>.<export>`; do not imply
  the Rust-only lifecycle is remotely callable.
- If the user asks for review or a second model's view, start with
  `peer_review`; do not convert that into implementation unless asked.
- If a single claim must be checked against graph evidence, use `oracle`; it
  writes a learn_pattern receipt only in explicit write mode. For durable
  proof, pair it with the `verification_*` receipt surface.
- If the work is a multi-head work graph rather than a single plan's task
  lifecycle, use the `multihead_*` family: `multihead_run` / `multihead_task`
  to open and shape it, `multihead_claim` / `multihead_next` to take work,
  `multihead_patch` / `multihead_proof` to submit, and `multihead_review` /
  `multihead_refine` for the review pass. Independent verification rides
  `multihead_spawn_verify` / `multihead_submit_verify`, with the verify sibling
  assigned to someone other than the author — the same separation the plan
  lifecycle above requires. In read-only mode only `action=status` is
  available.
- If work should run in the background or on another head, use Dispatch
  (`job_submit` / `job_list` / `job_note` / `job_archive`) or `spawn_session`
  for a room-visible spawned session. Both are local-node surfaces.
- If the user asks to rebuild, port, or establish parity with an existing
  system, route to `reverse_engineer_*` (target_plan, slice, compose, port,
  emit, validate) and `reconstruct` / `reconstruct_binary`.
- If the task is design-system or UI-audit shaped, the Design Scout tools
  (`design_extract`, `design_audit`, `design_drift`, `design_report`,
  `design_tokens`) are first-class; pair them with `design-engineering`.
- At the start of Rust-shaped work, `skill_apply` the Rust skill-pack so this
  head starts warm; `ensemble_select` chooses packs under budget when several
  could serve. Both are local-node surfaces.
- If the task is broad but actionable, use a short `theorize` pass, choose a
  default, and continue. Do not park in brainstorming.
- If hooks already injected a useful context brief, use it. If it is missing,
  stale, or contradicted by source code, refresh or inspect before relying on it.

Re-route whenever a material discovery changes the shape of the work, when a
third workaround appears in the same layer, before overlapping edits, and before
final claims.

## Liveness: the Product Packet is the live inventory

The family catalogs and this file teach what capabilities *mean*. They do not
tell you what is reachable right now. Hooks inject a "Theorems Harness Product
Packet" per session event carrying active and degraded capabilities, and that
packet is the live inventory:

- An active capability's directive and validation defaults are usable now.
- A degraded capability (`remote_unavailable`, `no_manifest`, ...) must not be
  taught, attempted, or silently worked around. Name the degradation in the
  report and use the documented fallback if one exists.
- When the packet and any document disagree, the packet wins.

Two further liveness rules:

- **Never teach a retired name.** `references/COMPATIBILITY.generated.md` is
  the authority on removed names and their replacements; removed names are
  documentation-only and must never re-enter routing prose or family catalogs.
- **Surfaces differ by deployment.** The bundled remote node exposes a subset
  of the local node. Memory writes (`encode`, `remember`, `relate`, `handoff`),
  the plugin host (`skill_*`), pack selection (`ensemble_*`), Dispatch
  (`job_*`), practice (`practice_*`), and `replay_last_run` are local-node
  surfaces today. Treat a missing verb as a degraded capability: name it, do
  not emulate it. Confirm with `tools/list` or `tool_search` rather than
  assuming this list is current.

## Adaptive Workflow

1. **Observe.** Check cwd/worktree, user intent, dirty files, relevant source,
   active context artifact, and pending mentions when another agent is involved.
2. **Choose.** Pick the next capability mix. A tiny task may be
   `observe -> execute -> validate -> report`; a complex task may add plan,
   coordination, peer review, and memory.
3. **Act.** Take the next bounded action. Prefer source-grounded edits and
   focused validation over broad theater.
4. **Check.** Run the narrow proof that matters: tests, build, browser, deploy,
   replay, screenshot, MCP response, or code inspection.
5. **Pivot.** If the evidence changes the task, update the checklist or route.
   If another agent is affected, coordinate before proceeding.
6. **Close.** Report truthfully. For high-signal lessons, encode or recommend a
   memory write. For risky multi-agent work, peer review before commit/PR.

## Public Command Role

- Primary command: `/harness`
- Utility commands:
  - `/coordinate` for cross-agent presence, mentions, stream checkpoints, and
    handoffs.
  - `/peer-review` for cross-frontier-model diff review before commit, PR, or
    launch-ready reporting.
  - `/encode` for feedback, solution, or postmortem memory.
  - `/research` for direct fractal expansion / gap-frontier discovery.
  - `/compute_code` for native CodeCrawler-backed code discovery, with graph-structural ranking fallback.
  - `/replay-last-run` for deterministic replay and integrity inspection of the
    most recent eligible run.
  - `/writing-engineering` for prose checks, including the integrated 1918
    Elements of Style ruleset.

The source-attributed practice system is ambient behavior rather than another
slash command. It binds planning, execution, verification, review, and
run-to-run learning into the active Harness run.

Compatibility commands such as `/execute` may remain installed, but new work
should prefer `/harness` plus adaptive routing.

## Focused capability guides

Load these only when the task enters the family; they are the progressive
detail layer rather than another global tool catalog:

- `identity-bindings` plus `references/IDENTITY_CAPABILITY.md` for typed
  `identityBindingStatus` / `identityBindingExplain`, flat
  `identity_binding_status` / `identity_binding_explain`, and the admitted
  identity/binding proof boundary.
- `context-management` plus `references/CONTEXT_CAPABILITY.md` for
  `contextStatus`, `contextExplain`, `refreshContext`, `invalidateContext`,
  flat `context_status`, `context_explain`, `context_invalidate`, and
  `harness_prepare`, including the incomplete PostToolUse/PreCompact epoch
  wiring.
- `commitments-policy` plus
  `references/COMMITMENTS_POLICY_CAPABILITY.md` for remote
  `writeCoordinationRecord`, `recordClaim`, `commitment_check`, and the
  Rust-only canonical `assert_typed_claim`, typed commitment, and constitution
  seams.
- `graph-lisp` plus `references/GRAPH_LISP_CAPABILITY.md` for crate-local
  `execute_capability`, admitted dynamic and GraphQL bounded pure
  read/eval/diff/explain, deterministic receipts, and the
  `external_executor_required` effect boundary.
- `data-reconstruction` plus
  `references/DATA_RECONSTRUCTION_CAPABILITY.md` for typed Data, persistent
  DataRegistry lineage, instant-KG, flat-only `datawave_ingest` and
  `resolve_ingest`, and
  `reverseEngineerCompose` through `reverseEngineerPort` with source and
  obligation discipline.
- `learning-evolution` plus
  `references/LEARNING_EVOLUTION_CAPABILITY.md` for canonical outcome evidence,
  flat `programmable_graph` evolve validation, and the Rust-only GEPA,
  ReasoningBank, and `theorem-evolve` boundaries.
- `agent-interop` plus `references/AGENT_INTEROP_CAPABILITY.md` for flat
  `composed_agent_run`, durable `head_call` streams, Head Call and ACP
  WebSockets, and the unprojected A2A client/runtime membrane.
- `coordination-operations` plus
  `references/COORDINATION_OPERATIONS_CAPABILITY.md` for rooms, typed records,
  streams, task-reference rooms, jobs, work graphs, session dispatch, and
  operational discovery/readiness.
- `graph-storage` plus `references/GRAPH_STORAGE_CAPABILITY.md` for GraphQL and
  flat reads, algorithms, admin mutations, caller-carried graph versions,
  resources, and the unprojected storage internals.
- `agent-contracts` plus `references/AGENT_CONTRACTS_CAPABILITY.md` for the real
  MCP/GraphQL error layers, family-specific pagination, result fetching,
  idempotency, and receipt interpretation.
- `solvers` plus `references/SOLVER_CAPABILITY.md` for the canonical
  `tool_search` -> `describe` -> `invoke` flow over `constraint.check` and
  `constraint.optimize`.
- `programmable-wasm` plus
  `references/PROGRAMMABLE_WASM_CAPABILITY.md` for installed app exports shaped
  `wasm_plugin:<plugin_id>.<export>` and the honest Rust-only durable lifecycle
  boundary.
- `verified-cognition` plus
  `references/VERIFIED_COGNITION_CAPABILITY.md` for safe composition of
  `constraint.check`, reconstruction, verification receipts, and the Plan
  lifecycle without a fictional workflow tool.

## Querying the multi-model store

RustyRed is one store with several access methods behind a single query surface,
not several databases. Treat retrieval as a choice of predicate roles, not a
choice of tools.

Two predicate roles:

- Filters narrow a set and compose by intersection: scalar equals, range,
  prefix; time range; geo within; text contains; graph reachable-from.
- Rankers score and order and compose by fusion: vector similarity (knn), text
  relevance (BM25), graph proximity (PPR). A ranker is never collapsed into a
  filter. Its scores carry through.

Current routing, until the planner-unify spec lands:

- Scalar, time, and join predicates go through `relational_query`, which costs
  access methods, intersects with roaring bitmaps, hash-joins, and returns a
  `PlanTrace`.
- Vector, geo, text, and graph-expand go through the single-modality tools:
  `vector_search`, `spatial_radius` and `spatial_bbox`, `fulltext_search`,
  `graph_neighbors` and the PPR tools.
- Do not pass knn, geo, text, or expand predicates to `relational_query` yet.
  The planner does not back them. It full-scans and returns unranked or
  unfiltered rows with no error. Route those predicates to the tools above.

After the unify spec lands:

- `relational_query` becomes the single entry for compound cross-modal
  retrieval. One call can fuse knn, geo, time, text, and expand under a fusion
  policy, RRF by default.
- Read the `PlanTrace` as the receipt: which access method fired per predicate,
  candidate set size, the kNN strategy (exact over candidates, or filtered
  HNSW), and the fusion kind. Read it the way you would read an EXPLAIN.

Carry this model: cost picks the cheapest method only among interchangeable ways
to evaluate the same filter. It never trades a ranking for a cheaper boolean. If
a result set looks like it lost similarity ordering or dropped recall, that is
the symptom of a ranker being treated as a filter. Report it as a bug, do not
treat it as expected.

## Capability details

Do not maintain a second global tool catalog here. Discover the active MCP and
GraphQL contracts, then load the focused family skill/reference selected above.
The generated compact compatibility projection belongs to HCM-031.

Use `references/CAPABILITY_CATALOG.generated.md` as the compact family index
and `references/COMPATIBILITY.generated.md` for accepted compatibility names
and removed aliases. Each focused family skill carries its own generated
catalog beside `SKILL.md`; do not copy those rows back into this adaptive skill.

### Preferred GraphQL code fields

Use `graphql_query` for `codeStatus`, `codeSearch`, `codeContext`,
`codeExplain`, `codeSpec`, `codeDrift`, `codeFeatures`, and `codeObligations`.
Use `graphql_mutate` for `ingestCodebase` and `reindexCodebase`. Introspect first
when the current schema is not in context. Status and compiler fields return a
typed repository revision claim; keep tenant, repository, generation, head SHA,
evidence ids, and missing evidence attached to the result. See
`references/CODE_CAPABILITY.md` for the exact GraphQL-to-flat mapping.

### Preferred GraphQL memory fields

Use `graphql_query` for `memory`, `memoryDoc`, `memoryArchive`, and nested
`MemoryDoc.links`/`MemoryDoc.related`. Use `graphql_mutate` for
`rememberMemory`, `reviseMemory`, `forgetMemory`, and `createHandoff`.
`rememberMemory` without `input.outcome` lowers to `remember`; with an outcome
it lowers to `encode`. Flat `recall`, `relate`, `self_recall_archive`,
`self_revise`, `forget`, and `handoff` are compatibility paths. `observe`,
`self_note`, `self_archive`, `retrieve_memory`, `turn_start`, and
`evidence_bundle` remain distinct flat-only operations when advertised.

Treat admission as the tenant/project authority. Keep `projectSlug`,
`rankSignals`, `episodeProvenance`, and `episodeProvenanceContentAddress` with
recalled evidence. Honor episode opt-out before capture, accept deterministic
deduplication on replay/import, and keep a raw episode out of canonical practice
until a same-scope clustered-outcome promotion receipt exists. See
`references/MEMORY_CAPABILITY.md` for the exact mapping and guardrails.

### Preferred GraphQL verification fields

Use GraphQL mutation `recordVerification` to atomically record a canonical
verification receipt, its support/attack evidence lineage, and any calibration
delta. Use GraphQL queries `verificationReceipt`, `verificationExplain`,
`verificationAllocate`, and `calibrationReliability` to read, explain, allocate,
and inspect reliability. Flat compatibility uses `verification_record`,
`verification_receipt`, `verification_explain`, `verification_allocate`, and
`calibration_reliability`.

Admitted tenant, actor, and binding claims are authoritative. Authenticated
actor and binding overwrite nested verifier self-report; head/model strings
remain reported runtime metadata, not signed identity. Confidence alone is not
proof, `inconclusive` does not update calibration, and a reliability
`admission_tier` is evidence weighting rather than authentication or action
authorization. See `references/VERIFICATION_CAPABILITY.md` for the exact input,
replay, graph-version, allocation, and reporting contract.

## Coordination Rule

The heads are one agent with several hands (`codex`, `claude-code`, `claude-ai`),
not separate workers dividing the repo. Coordinate as a unit:

- Read the room, intents, durable records, and mentions at turn-start, before
  planning edits.
- Write `coordination_intent` as an announcement: what you are doing now, which
  files or concepts your hands are on, and where semantic overlap may exist. It
  is not a lock.
- When your work semantically overlaps another head's work, build on its edit
  rather than yielding or waiting; held, not clobbered. A real disagreement is a
  `coordination_record` with `record_type: "tension"` that you work around,
  not a silent overwrite.
- Send `coordinate` with an `@actor` only for a block or a fork that changes the
  next action. Ordinary progress goes in your announcement summary.
- Close your announcement at turn-end. Use `coordination_record` with
  `record_type: "reflection"` for the handoff and `record_type: "decision"`
  for a load-bearing choice.

The durable model is room digest plus interrupt mailbox: membership, intents,
typed records, events, stream cursors, and pending mentions survive head sleep;
short-TTL presence only says who is fresh. Full protocol:
`skills/harness-coordinate/SKILL.md`.

Ambient coordination now flows over per-room streams. Subscribe once with
`stream_subscribe`, and at turn-start call `stream_read` to pull only the events
appended since your cursor, which replaces re-reading the whole room.
`stream_read` with advance consumes the window so the same events do not
reappear. Publish events with `stream_publish`; a publish with urgency block or
ask and a `target_actor` also pings that head through the mention and wake path,
so the interrupt channel rides the same stream. claude.ai still does not hold a
live listener, so the model is subscribe, then read the cursor delta at each
turn-start, not a long-running socket. `coordination_context` is still a valid
one-call orientation read; prefer `stream_read` once you are subscribed, since
it is the cursor-delta version of the same thing.

## Hook Enforcement Layer

The plugin hook layer makes the highest-risk harness disciplines deterministic:

- `SessionStart` and build-shaped `UserPromptSubmit` events inject the ambition
  frame so plans do not shrink the request before execution begins.
- Handoff-shaped prompts emit a session-bound
  `.harness/checklists/<plan-slug>--<plan-id>.json` projection; parallel sessions
  resolve only their own binding. The hook still mirrors it into a coordination
  record only until the Stop gate reads the plan substrate directly. The plan
  is the contract; `.harness/checklist.json` is only a legacy fallback.
- `Stop` blocks completion only while checklist items remain unresolved without
  verification evidence or a concrete deferral reason.
- `PostToolUse` records action, context, and coordination events without
  policing ordinary planning or status language.
- Investigation-shaped prompts inject the curiosity frame as an enricher, not a
  gate.
- `UserPromptSubmit` injects an ambient `## Code neighborhood` block when a
  tenant is set (`THEOREM_TENANT_ID`): PPR-ranked code hits over the merged
  committed-base + local-edit delta, with `file:line` and an "editing X reaches
  Y" impact block. Trust it as PPR-ranked; prefer drilling in by `node_id`
  (`compute_code` operation `context`/`explore`) over a fresh lexical search,
  and read the impact line before editing a load-bearing symbol.

## Output Discipline

- Do not ask the user to choose internal modes unless it is genuinely a product
  preference or unsafe to infer.
- Keep checklists as small as the work requires. A one-file fix may need only a
  two-line internal checklist; a launch or migration needs stable row IDs.
- Do not claim "done" unless validation supports it. Say partial, blocked,
  skipped, failed, or not-run when that is the truth.
- For UI visual work, include the UI Visual Milestone and the Do Not Downgrade
  gate from `../../references/UI_VISUAL_PROJECT_GATES.md`.
- For high-risk product, SDK, Redis, THG, deployment, or multi-agent work, use
  the relevant specialist agent or peer review before final claims.
- Encode only high-signal lessons. Keep secrets out of stored memory.
- Write a continuity pack before compaction, handoff, or a long pause when the
  next agent needs exact resume state.

## Anti-Patterns

- Freezing the whole session in `execute` after the evidence says to diagnose,
  coordinate, or refresh context.
- Treating `/harness mode=plan` as permission to avoid implementing an obvious
  bounded first slice when the user asked to ship.
- Treating `/harness mode=execute` as permission to skip design when a third
  workaround appears.
- Reporting hook or route success as product success without runtime evidence.
- Treating files as territory to reserve instead of announcements to build on; using
  message handshakes where reading the room and co-editing on overlap would be
  faster.
