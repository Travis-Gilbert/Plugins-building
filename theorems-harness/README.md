# Theorem's Harness

Dual-host plugin: works in both Codex and Claude Code from a single source. `plugin.manifest.json` is the canonical source for shared metadata and host-specific manifest payloads; the generated host manifests keep each platform's discovery contract intact.

## What's shared (both hosts read this)

- Shared skill packages under `skills/`, including the adaptive Harness,
  planning/execution, practice-system, replay, coordination, memory, code,
  identity and bindings, context management, commitments/policy, Graph Lisp,
  Data/reconstruction, stable solvers, verified cognition composition,
  learning/evolution, agent interoperability, coordination/operations,
  graph/storage, agent contracts, programmable WASM, writing, design, and Rust
  engineering surfaces.
- Agent profiles under `agents/*.md`.
- Shared references under `references/*.md`.
- Byte-stable per-family surface maps generated from
  `capabilities/families.json` and the source-derived MCP/GraphQL snapshot. See
  `references/CAPABILITY_CATALOG.generated.md` and
  `references/COMPATIBILITY.generated.md`.

A change to any of these flows to both hosts on next install / sync. There is no port to keep up to date.

## Adaptive slash/skill surface

`theorems-harness` packages Theorem's Harness, which is the user-visible
product layer. Slash commands and skills live here; the GraphQL MCP API is the
preferred tool bus, and the SDK sits underneath as typed helper plumbing.

`/harness` is an opt-in to harness behavior for the active task, not a narrow
mode selector. The agent should pick the best capability mix, reroute at
checkpoints, coordinate when another agent may overlap, validate claims, and
encode durable lessons only when they are high signal.

| Layer | Role |
|---|---|
| Slash commands | Human/agent entrypoints such as `/harness`, `/coordinate`, `/peer-review`, `/research`, `/encode`, `/compute_code`, `/replay-last-run`, `/writing-engineering`, and `/design-engineering` |
| Skills | Behavioral protocols for when and how to use those entrypoints |
| GraphQL MCP | Single remote HTTP `theorems-harness` server for graph reads, algorithms, code discovery, code ingest, harness run lifecycle, memory, coordination, and skill-pack surfaces |
| SDK | Typed client helpers used by scripts and compatibility utilities; not a separate user-facing command layer |

The older `theorem-context-sdk/claude-code` plugin is legacy host-adapter
plumbing. Grounded agent work belongs to this plugin's `/harness`; context
management uses the exact status, explanation, prepare, and invalidation
surfaces documented in `references/CONTEXT_CAPABILITY.md`.

## Manifest source and generated host manifests

| File | Read by | Purpose |
|---|---|---|
| `plugin.manifest.json` | maintainer tooling | Canonical source for the release version, shared metadata, MCP payload, release file set, and host manifest payloads |
| `.claude-plugin/plugin.json` | Claude Code | Identity + `mcpServers` registration |
| `.codex-plugin/plugin.json` | Codex | Identity + `interface` block (displayName, capabilities, defaultPrompt) + Codex hook manifest pointer |

Regenerate and verify the host manifests with:

```bash
python3 scripts/sync-plugin-manifests.py theorems-harness --check
python3 scripts/sync-plugin-manifests.py theorems-harness
```

The same generator writes `.mcp.json` from the canonical `mcpServers` block.
Keep local MCP endpoints and credentials in host/user configuration or the
documented environment variables; never write them into a release artifact.

Before a release, build and verify an isolated cache artifact with:

```bash
scripts/check-plugin-release-parity.sh theorems-harness
```

The gate reports the canonical version, artifact content hash, MCP fingerprint,
and rollback shape. The marketplace catalog records the same artifact content
hash next to the generated version. The clean-install and resync fixtures use a
temporary home; they do not touch the real installed cache. For a manual
reversible cache materialization, use `scripts/plugin_release.py install` with
`--backup-dir` and keep the emitted receipt. Roll back by restoring both the
previous version directory and the matching `installed_plugins.json` backup,
then start a new host session. Release publication and the live installed-cache
refresh remain separate, explicitly authorized operations.

## Hook manifests and shared runtime

| Path | Purpose |
|---|---|
| `hooks/hooks.json` | Claude Code lifecycle hooks. SessionStart begins a run, loads codebase/coordination context, arms Writing Engineering, and injects the standing Harness frame. Prompt, tool, file-change, Stop, and PreCompact hooks record context, actions, receipts, checklist evidence, and continuity. |
| `hooks/codex-hooks.json` | Codex lifecycle hooks. Mirrors the supported turn/tool/Stop lifecycle with `${PLUGIN_ROOT}` paths, session-bound checklist projections, action/context receipts, and Writing/Design Engineering receipts. Codex `PreToolUse` only authorizes the Harness MCP namespace. |
| `scripts/*.sh` | Shared bash implementations of the hooks. Host-aware, fail-open, pure bash + curl + jq. |
| `scripts/peer-review-request.sh` | Creates `.theorem/peer-review/` packets and optionally sends a coordination mention for cross-model review before commit or launch reporting. |
| `.mcp.json`, `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json` | Register the single remote HTTP MCP server named `theorems-harness`. There is no bundled Node MCP server or local proxy. |

Every lifecycle event also writes a local hook-doctor receipt to
`.theorem/hook-doctor/events.jsonl`. Stop review receipts land in
`.theorem/review/latest-repo-hygiene.json` and
`.theorem/review/latest-language-checks.json` before any best-effort remote
append, so a remote MCP outage no longer makes hook execution invisible.

The `mcpServers` field registers one server, `theorems-harness`, pointing at
`https://rustyredcore-theorem-production.up.railway.app/mcp`. The old local
Node MCP and the separate RustyRed proxy are removed; hooks call native tools
through `theorem_native_call`.

## GraphQL MCP surface

Version `0.9.4` is the capability-complete-mirror plugin contract. When
`tools/list` exposes
`graphql_query`, `graphql_mutate`, and `graphql_introspect`, agents should use
`graphql_introspect` to discover the schema and then read or write memory,
coordination, jobs, graph, code, and run surfaces through GraphQL. On servers
with `graphql_default_surface` enabled, flat tools already covered by GraphQL
may be hidden from `tools/list`.

Flat tools remain a compatibility and diagnosis path. Use them only when a
local/dev server does not expose GraphQL yet, a host session is intentionally
testing legacy flat-tool behavior, or GraphQL itself is the suspected failure
surface.

The transport endpoint does not change for hosted users: Claude Code, Claude.ai,
and Codex plugin installs all point at the remote Railway MCP unless a developer
intentionally overrides `THEOREM_HARNESS_MCP_URL` for local work.

The MCP may advertise these launch-facing tools through `tools/list`:

Host UIs may show these tools with a plugin or app prefix, for example
`theorems-harness recall`, `Theorem's Harness Recall`, or
`mcp__codex_apps__theorems_harness._recall`. Treat that prefix as the host's
routing/display label, not as a different memory system. In user-facing reports,
prefer the product language ("Harness recall", "Harness encode", "Harness
memory") and include the wire-level identifier only when it matters.

- Identity and bindings: prefer typed GraphQL `identityBindingStatus` and
  `identityBindingExplain`. Flat compatibility uses `identity_binding_status`
  and `identity_binding_explain`; both surfaces accept no identity arguments.
- Context and runs: prefer GraphQL `contextStatus`, `contextExplain`,
  `refreshContext`, and `invalidateContext`. Flat compatibility uses
  `context_status`, `context_explain`, `context_invalidate`, and
  `harness_prepare`, alongside `harness_append_transition`, `harness_run`,
  `replay_last_run`, and `harness_kg_status`.
- Code: prefer GraphQL `codeStatus`, `codeSearch`, `codeContext`,
  `codeExplain`, `codeSpec`, `codeDrift`, `codeFeatures`, and `codeObligations`,
  with `ingestCodebase`/`reindexCodebase` mutations. Flat compatibility uses
  `compute_code` operations for status/search/context/explain, `code_ingest`
  for ingest/reindex, and `code_compile_spec`, `code_spec_drift`,
  `code_extract_features`, and `code_implementation_obligations` for compiler
  reads. The old `code_search` name is dispatch-compatible only; it is not
  advertised.
- Graph and storage: prefer typed GraphQL graph/search/algorithm fields. Flat
  query/explain/relational/index diagnostics and graph-version value operations
  remain; administrative designation/bulk tools require admin admission.
- Web: `rustyweb_search_acquisition`, `browse_for_me`, `browse_with_me`, `web_consume`
- Skill packs: `skill_list`, `skill_get`, `skill_publish`, `skill_apply`
- Coordination and jobs: prefer typed GraphQL room, task-reference-room,
  stream, work-graph, and job fields. Flat compatibility includes
  `coordination_room`, `coordination_intent`, `coordination_record`,
  `read_intents_for_room`, `coordinate`, `mentions`, `presence`, `stream_*`,
  and `job_*`. Decision/tension/reflection are `coordination_record` types, not
  dedicated tools.
- Multi-head substrate: `multihead_run`, `multihead_task`, `multihead_claim`, `multihead_patch`, `multihead_proof`, `multihead_review`
- Memory and learning: `recall`, `remember`, `relate`, `observe`, `self_note`,
  `self_revise`, `self_archive`, `self_recall_archive`, `encode`, `forget`,
  `handoff`, `retrieve_memory`, `turn_start`, and `evidence_bundle`
- Verification and calibration: prefer GraphQL `recordVerification`,
  `verificationReceipt`, `verificationExplain`, `verificationAllocate`, and
  `calibrationReliability`. Flat compatibility uses `verification_record`,
  `verification_receipt`, `verification_explain`, `verification_allocate`, and
  `calibration_reliability`.
- Data and instant KG: prefer GraphQL `dataSchema`, `dataRecords`,
  `dataRecord`, `dataLinks`, `dataQuery`, `dataRetrieve`, `dataViews`,
  `dataView`, `upsertDataView`, and the six `harnessKg*` reads. Flat
  compatibility uses `query_data` and exact `harness_kg_*` tools.
- Reconstruction and resolution: prefer `reverseEngineerCompose` through
  `reverseEngineerPort`; exact flat compatibility uses `reverse_engineer_*`.
  `resolve_ingest`, `resolve_entities`, `resolve_explain`,
  `memory_dedup_report`, `datawave_ingest`, `reconstruct`, and
  `reconstruct_binary` are flat-only.
- Learning and evolution: use canonical verification/calibration plus ordinary
  memory/run outcome surfaces. Flat `programmable_graph` with
  `action: "evolve"` validates a standing-program proposal; GEPA,
  ReasoningBank, and `theorem-evolve` lifecycles remain Rust-only.
- Agents and interop: flat `composed_agent_run` runs one admitted composed turn.
  Durable Head Calls use `stream_publish`, `stream_read`, and `stream_ack` with
  `kind: "head_call"`; A2A remains Rust-only and ACP is a server WebSocket.
- Dynamic capabilities: `tool_search`, `describe`, and `invoke`. Stable solver
  affordances are `constraint.check` and `constraint.optimize`. Installed app
  WASM exports use `wasm_plugin:<plugin_id>.<export>`.

For memory, prefer GraphQL `memory`, `memoryDoc`, `memoryArchive`, nested
`links`/`related`, and the `rememberMemory`, `reviseMemory`, `forgetMemory`, and
`createHandoff` mutations. Outcome-bearing `rememberMemory` is the typed encode
path. Flat tools remain compatibility or flat-only operational paths. Preserve
`projectSlug`, `provenance`, `rankSignals`, `episodeProvenance`, and
`episodeProvenanceContentAddress` with recalled evidence. The exact mapping,
scope rules, opt-out marker, retro-import recovery contract, and
practice-promotion firewall live in `references/MEMORY_CAPABILITY.md`.

Identity is resolved from the authenticated admitted session, never from tool
arguments or configuration alone. Keep principal, project selection, binding,
active heads, scopes, budget, provenance, conflicts, warnings, and receipt hash
together. Typed GraphQL and flat MCP parity, refusal rules, and the remaining
live two-tenant/admission gaps live in `references/IDENTITY_CAPABILITY.md`.

Context is a scoped lease and generation ledger. `harness_prepare` reuses or
compiles; GraphQL `refreshContext` explicitly compiles; `context_invalidate` or
`invalidateContext` advances the scoped epoch. Current `PostToolUse` and Claude
`PreCompact` hooks record evidence or flush memory but do not advance that
epoch, and Codex has no `PreCompact` hook. See
`references/CONTEXT_CAPABILITY.md` for disposition reasons, stale/evicted
generations, and the admitted-session proof boundary.

Remote commitments are coordination standing decisions: create them through
GraphQL `writeCoordinationRecord` or flat `coordination_record`, use the real
flat lifecycle tools including `commitment_check`, and use GraphQL `recordClaim`
only for Coordination V2 claims. The canonical Rust seam is
`assert_typed_claim` plus typed commitment and `Constitution::refusal` APIs; it
is not remotely projected yet. See
`references/COMMITMENTS_POLICY_CAPABILITY.md` for the evidence, history,
witness, and policy-receipt boundaries.

Canonical verification atomically binds the claim, support/attack evidence,
lineage, verifier, method, graph version, result, and calibration delta. Admitted
tenant, actor, and binding claims are authoritative; head/model labels remain
reported metadata, confidence is not proof, and calibration admission tier is
not authentication. The exact mapping and reporting rules live in
`references/VERIFICATION_CAPABILITY.md`.

Data and reconstruction have deliberately different projections. Typed Data,
instant-KG, and the seven source reconstruction stages coexist with flat-only
DATAWAVE, resolve, compound reconstruction, and binary reconstruction. Exact
source pins, provenance, `unknowns`, `unresolved_obligations`, and validation
receipts marked `not_run` must survive the workflow. See
`references/DATA_RECONSTRUCTION_CAPABILITY.md`; neither emit nor port is a live
or end-to-end parity oracle.

Stable constraint actions are dynamic affordances rather than dedicated flat
or GraphQL tools. Discover, describe, and invoke them through the gateway, then
interpret the typed operation receipt and its proof eligibility. Exact schemas,
budgets, refusal semantics, and current cancellation/persistence limits live in
`references/SOLVER_CAPABILITY.md`.

Verified cognition is currently composition, not a dedicated tool. Load
`verified-cognition` and combine `constraint.check`, reconstruction stages,
canonical verification receipts, and the Plan lifecycle while keeping proposal
and proof separate. The verified-decision, consistency, reconstruction,
repair, and voice orchestrators remain unimplemented. See
`references/VERIFIED_COGNITION_CAPABILITY.md`.

Learning and evolution reuse canonical outcome, memory, run, and practice
evidence. Load `learning-evolution`; the callable flat evolve seam is proposal
validation through
`programmable_graph`, not a GEPA train/promote action. Candidate scores,
lineage, held-out outcomes, guardrail discounts, and independent verification
must stay attached. See `references/LEARNING_EVOLUTION_CAPABILITY.md`.

Agent interoperability is not one transport. Load `agent-interop`.
`composed_agent_run` is a
tenant- and binding-admitted flat write; Head Calls are durable stream events
with an optional authenticated WebSocket accelerator; A2A registration and
invocation are Rust-only; and ACP is exposed at `/v1/commonplace/acp/ws` when a
server-local agent binary is available. Configured providers are not live proof
without invocation receipts. See `references/AGENT_INTEROP_CAPABILITY.md`.

Coordination and operations are several state machines, not one agent task
endpoint. Load `coordination-operations` for exact room/record semantics,
durable stream cursors and ack, derived job state, work graphs, GitHub Actions
session dispatch, and `/health` / `/ready` / `/version` proof boundaries. See
`references/COORDINATION_OPERATIONS_CAPABILITY.md`.

Graph access uses typed GraphQL where covered, flat-only query/version
diagnostics where needed, and a separate administrative mutation gate. Load
`graph-storage`; graph-version repositories are caller-carried values and
checkout is not a live rollback. See `references/GRAPH_STORAGE_CAPABILITY.md`.

MCP, GraphQL, HTTP, and domain results do not yet share one envelope. Load
`agent-contracts` when interpreting error layers, family cursors, result-fetch
byte offsets, retries, idempotency, or receipts. See
`references/AGENT_CONTRACTS_CAPABILITY.md`.

Programmable WASM keeps its durable Rust registry lifecycle separate from the
callable exports of installed app manifests. Agents may use the dynamic gateway
for installed exports, but the publish/promote/inspect/selected-invoke/rollback
lifecycle has no MCP or GraphQL projection yet. See
`references/PROGRAMMABLE_WASM_CAPABILITY.md`.

Graph Lisp pure read/eval/diff/explain is currently the crate-local
`rustyred_thg_graph_lisp::execute_capability` envelope. It has no MCP, GraphQL,
or dynamic gateway projection, and `dynamic_call` refuses with
`external_executor_required` even when granted. Exact limits, receipt fields,
typed errors, graph-version limits, and replay guarantees live in
`references/GRAPH_LISP_CAPABILITY.md`.

The ambient practice graph is selected through Ensemble and compounds through
the ordinary run/event/episode path. It does not add a second workflow engine
or memory store. The 1918 Elements rules extend Writing Engineering in the same
pack and receipt; there is no parallel Elements mode.

Lifecycle writes use a durable session queue under
`.theorem/ambient/<session>/`. Stable request keys make hook retries and lost
responses idempotent; an atomic enqueue sequence preserves host event order
across prompt, tool, and compaction boundaries while one short-lived worker
drains without blocking the agent. Transport or MCP refusals, including MCP
`result.isError`, leave the call queued and mark `status.json` degraded.
Malformed records move to an explicit `dead-letter/` directory so they cannot
starve later valid calls; the degraded status reports pending, acknowledged,
and dead-letter counts. `scripts/ambient-health-hook.sh` surfaces that state at
SessionStart and prompt boundaries, while `scripts/ambient-status.sh --cwd
<repo> --session <id> --refresh` combines local delivery health with the real
`harness_run`, `context_status`, and `context_explain` reads.

The runtime selects practices at typed run boundaries and performs episode
capture plus Compound Engineering attribution when `RUN.CLOSED` is accepted.
The current catalog does not register `practice_status`, `practice_explain`, or
a direct close-harvest receipt read, so ambient diagnostics report those gaps
instead of aliasing `ensemble_select` or claiming unobservable live evidence.

## Configuration

Codex plugin hooks are off unless the host config enables them:

```toml
[features]
plugin_hooks = true
```

Claude Code uses `hooks/hooks.json`; Codex uses the explicit `hooks` path in `.codex-plugin/plugin.json` so it loads `hooks/codex-hooks.json`.

| Env var | Default | Purpose |
|---|---|---|
| `THEOREM_API_KEY` | empty | Compatibility bearer token fallback for native MCP calls when `THEOREM_HARNESS_API_TOKEN` is not set. |
| `THEOREM_TENANT_ID` / `THEOREMS_HARNESS_TENANT` / `RUSTYRED_THG_TENANT` / `THEOREM_CONTEXT_TENANT_SLUG` / `THEOREM_TENANT_SLUG` | empty | Tenant slug for native calls and code KG hooks. The production harness tenant is `Travis-Gilbert`. |
| `THEOREM_HARNESS_MCP_URL` | `https://rustyredcore-theorem-production.up.railway.app/mcp` | Primary native Theorem MCP URL used by hook scripts. |
| `THEOREM_HARNESS_API_TOKEN` | empty | Optional Bearer token for native Theorem RustyRed MCP writes. |
| `THEOREM_LINT_MCP_URL` | `http://127.0.0.1:8380/mcp` | Local dynamic-gateway endpoint used for host-filesystem lint checks. It never falls back to the remote Harness URL. |
| `THEOREM_LINT_API_TOKEN` | empty | Optional Bearer token used only for the local lint endpoint. Production Harness tokens are never forwarded to lint. |
| `THEOREM_ACTOR` | host actor | Optional actor override for MCP coordination tools. When omitted, the MCP server defaults to `codex` in Codex-hosted plugin runs and `claude-code` otherwise, so mention reads do not fall back to the API-key actor. |
| `THEOREM_PROSE_CHECK_BIN` / `THEOREM_DESIGN_CHECK_BIN` | empty | Optional explicit checker binary paths for writing and design engineering receipts. When unset, hooks search `PATH`, `~/.cargo/bin`, plugin `bin/`, and repo-local Cargo target paths. |
| `THEOREMS_HARNESS_THG_API_TOKEN` | empty | Optional Bearer token for RustyRed-THG direct graph mirrors. |
| `THEOREMS_HARNESS_RUSTYRED_MCP_URL` / `RUSTYRED_THG_MCP_URL` | `https://rustyredcore-theorem-production.up.railway.app/mcp` | Compatibility fallback URL for hook scripts when `THEOREM_HARNESS_MCP_URL` is unset. |
| `THEOREM_BUDGET_TOKENS` | `4000` | Default Context Artifact budget |
| `THEOREM_ACTION_RAIL` | `record` | One of `off`, `record`, `enforce` |
| `THEOREM_REVIEW_MODE` | `advisory` | Shared Stop review mode for repo hygiene and language checks. Use `enforce` to block on hard failures, or `shadow` for receipt-only mode. |
| `THEOREM_REPO_HYGIENE_MODE` / `THEOREM_LANGUAGE_REVIEW_MODE` | `advisory` | Per-hook overrides when `THEOREM_REVIEW_MODE` is unset. |
| `THEOREM_REVIEW_LANGUAGE_CHECKS` | `1` | Set to `0` to skip changed-language review checks. Defaults cover Rust, JavaScript, TypeScript, CSS, Python, C, C++, Java, SQL, and C#. |
| `THEOREM_REVIEW_RUN_TESTS` | `0` | Set to `1` to include project test commands in the changed-language review pass. |
| `THEOREM_REPO_HYGIENE_LARGE_FILE_BYTES` | `5242880` | Size threshold for large untracked-file hygiene warnings. |
| `THEOREM_DEBUG` | `0` | Set to `1` to log hook activity to stderr |
| `THEOREM_AMBIENT_SYNC` | `0` | Test/oracle switch that drains ambient calls inline. Normal hooks leave this off so delivery is non-blocking. |
| `THEOREM_PEER_REVIEW_BASE` | empty | Optional base ref/commit used by `scripts/peer-review-request.sh` when preparing a peer-review packet. Defaults to upstream merge-base or `HEAD`. |
| `THEOREM_PEER_REVIEW_ACTOR` | host actor | Optional actor override for peer-review packets. |
| `THEOREM_PEER_REVIEW_TARGET` | other main agent | Optional target override for peer-review packets. |

## Install (Claude Code)

```bash
# Enable in ~/.claude/settings.json:
#   "theorems-harness@codex-marketplace": true
```

### Skill-only bootstrap

For a fresh agent that does not have the marketplace plugin enabled yet, install
the harness skill bundle directly into both Claude Code and Codex:

```bash
curl -fsSL https://raw.githubusercontent.com/Travis-Gilbert/claude-marketplace/main/theorems-harness/scripts/install-harness-skills.sh | bash
```

From a local checkout:

```bash
./scripts/install-harness-skills.sh
./scripts/install-harness-skills.sh --bundle full
```

The default `core` bundle installs `/harness`, coordination, the ambient
practice system, code discovery, encode, research, peer review, and execute
skills. The `full` bundle adds replay, Data/reconstruction,
learning/evolution, agent interoperability, coordination/operations,
graph/storage, agent contracts, solvers, verified cognition composition,
programmable WASM, writing, identity and bindings, context management,
commitments/policy, Graph Lisp, design, and specialist skills. Use
`--claude-only` or `--codex-only` for one host.

### Capability projection validation

Regenerate checked-in family catalogs after refreshing the source snapshot,
then validate semantic links and byte stability:

```bash
python3 scripts/generate_harness_capability_projections.py theorems-harness
python3 scripts/validate_plugin.py theorems-harness
```

The release gate also requires a compact live catalog and the installed cache:

```bash
THEOREM_CAPABILITY_LIVE_CATALOG=/path/to/live-surfaces.json \
  scripts/check-harness-capability-drift.sh --plugin --installed-cache
```

The compact live artifact has sorted `flat_mcp`, `graphql`, and `dynamic`
name arrays. HCM-004's live collector owns producing that observation; the
plugin does not relabel its source snapshot as live evidence.

`capabilities/source-surfaces.json` is generated from
`rustyred-thg-mcp::harness_capability_source_catalog`; it is not edited by hand.

## Install (Codex)

1. Enable the plugin in Codex.
2. Turn on plugin hooks in repo or user config:

```toml
[features]
plugin_hooks = true
```

3. Restart the session so Codex reviews and trusts the bundled hook commands.

## Native MCP calls hooks exercise

- `harness_prepare` (compile the Context Brief from Ensemble selection plus memory recall)
- `harness_append_transition` (append run lifecycle events)
- `harness_run` (read run event ledgers)
- `context_status` and `context_explain` (read the admitted context lease and lineage)
- GraphQL code fields for ingest/reindex/status/search/context/explain/spec,
  drift, features, and obligations; flat hooks use `compute_code` and
  `code_ingest` where needed
- `coordination_room`, `coordination_intent`, `coordination_record`,
  `coordinate`, `mentions`, `presence`, and durable stream operations
- `remember`, `recall`, `relate`, `self_note`, `self_revise`, `self_archive`, `self_recall_archive`, `encode`

Failure semantics: every hook fails open. Backend 500, missing jq, malformed responses all result in `{"continue": true}` so the user's session never breaks because the plugin had a bad day.

Offline ambient proof is deterministic and does not touch installed state or a
live tenant:

```bash
scripts/check-harness-ambient-session.sh --tenant Travis-Gilbert
```

Use `--mode local --mcp-url http://127.0.0.1:<port>/mcp` for an explicit local
host. Live mode additionally requires `THEOREM_AMBIENT_LIVE=1` and an admitted
token; it remains blocked until the server projects direct practice and
close-harvest diagnostics. Fixture success is never reported as live evidence.

## Live tool-surface drift gate

Capability teaching is generated into `capabilities/families.json` and the
family catalogs; retired names live in `references/COMPATIBILITY.generated.md`
and are documentation-only. Those artifacts are pinned to a source-catalog
snapshot, so they cannot tell you whether the *running* server has drifted from
what the plugin teaches. `scripts/regen-routing.sh` closes that gap by asking a
live server directly:

```sh
# refresh the snapshot from a live node
scripts/regen-routing.sh --url http://127.0.0.1:8380/mcp

# or from a Theorem checkout / an existing source-catalog dump
scripts/regen-routing.sh --cargo /path/to/Theorem/rustyredcore_THG
scripts/regen-routing.sh --from-file catalog.json

# pre-bump drift gate
scripts/regen-routing.sh --url http://127.0.0.1:8380/mcp --check
```

It writes only `references/TOOL_SURFACE.md` — drift evidence, never a second
teaching catalog, and never a skill. Run `--check` before a version bump. A
real skew is expected whenever the running node predates or postdates the
pinned snapshot; read the diff before assuming it is noise.

`--check` needs a server or a dump, so it cannot run offline. The parts that
can are enforced by `tests/tool-surface-snapshot.sh`, which runs in the normal
suite: it catches a hand-edited snapshot (declared tool count vs. actual rows)
and fails if the generator ever regains the ability to write into a skill.
