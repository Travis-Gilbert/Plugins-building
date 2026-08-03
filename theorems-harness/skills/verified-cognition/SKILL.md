---
name: verified-cognition
description: "Use when a decision, consistency check, reconstruction, repair, or voice workflow must separate proposals from proof using real receipts and the source-owned verified-cognition protocol, while respecting its current unprojected boundary."
---

# Verified cognition

Generated surface map: [capability catalog](./CAPABILITIES.generated.md).

Read `../../references/VERIFIED_COGNITION_CAPABILITY.md` plus the capability
guide for every primitive you use.

The source tree implements a bounded receipt-led orchestration protocol for
decision, consistency, reconstruction, repair, and voice workflows, plus an
eight-case adverse-fixture contract checker. It is not yet exposed through MCP
or GraphQL and does not persist its workflow chain in the graph. In an agent
session, compose only advertised surfaces:

1. Anchor the claim, inputs, graph version, repository revision, and source SHA
   that matter.
2. Use dynamic `constraint.check` only for claims representable by its bounded
   SMT schema. Read `proof_eligible`; preserve unknown, refusal, fallback,
   timeout, and cancellation dispositions.
3. Use `reverseEngineer*` or exact `reverse_engineer_*` stages for
   reconstruction. Preserve `unknowns`, hazards, `unresolved_obligations`,
   `needs_review`, and validate receipts marked `not_run`.
4. Run the real domain oracle outside the proposal-producing stage.
5. Record actual evidence with `recordVerification` or
   `verification_record`, then inspect it with `verificationExplain` or
   `verification_explain`.
6. When the work is Plan-backed, preserve `claim` -> `patch_proposed` ->
   `spawn_verify` -> `submit_verify` -> `prove` -> `done` and its independent
   reviewer boundary.

Do not route to invented verified-decision, consistency, reconstruction,
repair, voice, rewrite-pack, conflict-witness, or parity workflow tools. Repair
uses the ordinary bounded edit-and-oracle loop. Voice has no current verified
cognition transport. There is no callable orchestration shortcut for these
compositions. The repository protocol can validate replayable chains and fail
at the first unmet obligation, but it is source-only until MCP/GraphQL
projection, authoritative receipt loading, and graph persistence land.
