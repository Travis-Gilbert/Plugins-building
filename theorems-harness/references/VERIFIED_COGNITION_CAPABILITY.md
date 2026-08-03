# Verified Cognition Composition

Verified cognition has a source-owned, deterministic orchestration protocol
over real solver, reconstruction, code-intelligence, verification, Graph Lisp,
Writing Engineering, and Plan receipts. It supports verified decision,
consistency, reconstruction, repair, and voice workflow kinds without creating
a second solver or verifier. There is no monolithic `verifiedCognition` tool or
current MCP/GraphQL projection.

## Implemented protocol boundary

In the upstream `Travis-Gilbert/Theorem` repository,
`rustyredcore_THG/crates/rustyred-thg-mcp/src/verified_cognition.rs` validates
bounded workflow ids, claims, anchors, obligations, and receipt steps. It
separates caller proposals from proof-eligible evidence, requires exact
witnesses where the workflow calls for one, preserves unresolved obligations,
and builds a SHA-256-linked receipt chain. Finalization refuses at the first
missing or unsupported obligation.

That repository's `scripts/check-verified-cognition-contracts.sh` compiles the
module directly and runs eight successful and adverse fixtures. It also checks
that every named solver, reconstruction, verification, Graph Lisp, code, and
Writing Engineering source is a real registered capability rather than an
invented workflow tool.

The protocol currently accepts typed receipt metadata supplied by its Rust
caller. It does not reload authoritative graph receipts, persist its own receipt
chain, or expose MCP/GraphQL operations. Those boundaries must land before an
agent-callable workflow can claim substrate-backed orchestration.

## Available primitives

- Dynamic `constraint.check` and `constraint.optimize` return typed operation
  receipts. Only `solver.proof_eligible` authorizes treating a solver outcome as
  proof. See `SOLVER_CAPABILITY.md`.
- GraphQL `recordVerification`, `verificationReceipt`, and
  `verificationExplain`, with flat `verification_record`,
  `verification_receipt`, and `verification_explain`, bind actual evidence,
  graph version, verifier, method, result, and calibration. See
  `VERIFICATION_CAPABILITY.md`.
- The seven `reverseEngineer*` mutations and `reverse_engineer_*` flat tools
  produce reconstruction artifacts, receipts, unknowns, and unresolved
  obligations. See `DATA_RECONSTRUCTION_CAPABILITY.md`.
- The durable Plan lifecycle can preserve implementation and independent review
  evidence through `claim` -> `patch_proposed` -> `spawn_verify` ->
  `submit_verify` -> `prove` -> `done`.

## Safe compositions

### Decision or consistency question

1. State the claim and its graph/input anchors.
2. If it can be represented by the bounded SMT contract, invoke
   `constraint.check` through `tool_search` -> `describe` -> `invoke`.
3. Keep a satisfiable model, unsat witness, unknown, refusal, fallback, timeout,
   and cancellation distinct. Do not promote a non-proof-eligible remote or
   fallback result.
4. Run the domain oracle that the claim actually requires.
5. Call `recordVerification` only with the observed evidence and result; use
   `verificationExplain` to inspect the receipt and its freshness.

This is a manual verified-decision or consistency composition, not a callable
`verified_decision` or `consistency_check` workflow.

### Reconstruction question

1. Use an explicit source SHA when exact source identity matters.
2. Run the needed `reverseEngineer*` stages and preserve `unknowns`, hazards,
   and `unresolved_obligations`.
3. Treat validate receipts with `not_run` as planned commands, not proof.
4. Apply the emitted patch and execute real target-checkout structural,
   semantic, and behavioral tests.
5. Record and explain verification receipts for the executed oracles.

This composition can produce a replayable chain of stage and verification
receipts. The source protocol can validate that chain, but an agent session must
still assemble it manually. It does not automatically execute rewrite packs,
conflict-directed repair, or an end-to-end parity oracle.

### Repair work

Use the normal plan/execution loop: preserve the failing witness, propose a
bounded patch, run the relevant oracle, obtain independent Plan verification
when required, and record only the resulting proof. There is no callable
`repairWorkflow`, `rewrite_pack`, or constrained-repair capability yet.

## Proposal versus proof

Keep these categories separate:

- solver output whose receipt says `proof_eligible: false` is a proposal or
  diagnostic;
- reconstruction IR, plans, scaffolds, emitted patches, `needs_review`, and
  `not_run` receipts are proposals with obligations;
- a verification record describes the evidence supplied to it; it does not
  retroactively execute a missing oracle;
- Plan `done` requires its real lifecycle and receipt generation, not prose;
- an unresolved or undischargeable obligation stays unresolved.

## Not callable today

Do not invent or route to dedicated verified cognition, verified decision,
consistency, reconstruction, repair, voice, rewrite-pack, conflict-witness, or
semantic-parity workflow names. In particular, voice has no verified-cognition
surface in the current substrate. Report that gap instead of substituting a
model-generated answer.

The orchestration module, protocol fixtures, adverse-case contract checker,
exact-witness requirements, structural-plus-semantic parity obligations,
rewrite-pack lineage requirements, obligation-led repair rules, and voice
workflow rules are implemented in the source contract. The protocol preserves
witnesses supplied by real capabilities; it does not manufacture them.
MCP/GraphQL projection, authoritative receipt loading, graph persistence, and a
direct `prose-check` transport remain HCM-016 implementation work.
