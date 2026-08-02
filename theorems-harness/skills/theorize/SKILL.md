---
name: theorize
description: Superseded compatibility copy. The canonical Theorize capability is the v0.4 skill in Travis-Gilbert/Theorems-Harness; do not evolve this marketplace copy independently.
---

# Theorize

> **Superseded:** This marketplace copy is retained for compatibility and
> historical installs. The canonical source is
> `Travis-Gilbert/Theorems-Harness/skills/theorize/SKILL.md` at v0.4 (source
> commit `49ae273d2292512bc7cc456e96e756aa0fdd9cf6`). New behavior and fixes land
> there; this file must not diverge silently.

Theorize is the Harness capability for turning fuzzy intent into a
production-shaped problem model before the wrong implementation begins. It is
not brainstorming theater. It uses adversarial clarification, repo grounding,
and explicit decision capture, then converts the result into a planning input
or a direct execution call.

Prefer `/harness` (which routes here when option pressure is present).
`/theorize` remains a compatibility entrypoint for users who explicitly want a
theorem brief as the deliverable.

## When To Theorize

Use this capability when at least one is true:

- multiple credible approaches exist and the wrong choice would cause real
  churn
- the user used hedged or fuzzy language ("could," "maybe," "I wonder")
- a key term is overloaded across systems ("harness," "context," "runtime")
- repo evidence directly contradicts a stated assumption
- a question would be cheaper to resolve on paper than in code

Do not theorize when the user has clearly committed to a path, the task is
obvious from the repo, or the work is small enough that exploration is more
expensive than just trying it.

## Operating Posture

- Reframe the request in production terms before evaluating options.
- Prefer live code over historical plans. When docs and code disagree, say so
  plainly.
- Separate facts from assumptions. Label `Assumption`, `Gap`, `Tension`,
  `Decision` where the distinction matters.
- Ask at most one human-judgment question at a time, and only when the answer
  cannot be discovered locally.
- Include a recommended answer with every user-facing question.
- Resolve dependency order: upstream decisions first.
- Challenge convenience solutions that hide deferred work or validation gaps.

## Inputs

- a fuzzy user task ("we should probably...", "could we...", "what if...")
- a contested design decision
- a partial implementation that needs a frame check
- a spec that contradicts the live code
- a multi-option PRD that needs a recommendation

## Workflow

1. Restate the current condition from source, tests, docs, and runtime seams.
2. Identify intent, target outcome, and timing pressure.
3. Inspect the narrowest relevant code/doc surface first.
4. Build a small option set with concrete tradeoffs. Two real options is
   enough; five fake ones is theater.
5. Recommend one path. Name what would falsify the recommendation.
6. Convert the result into a planning input (`/harness mode=plan`) or, if the
   decision unlocks immediate action, a direct execution input
   (`/harness mode=execute`).

## Output

Right-size the deliverable:

- Small clarifications: 2-4 sentences inline, no template.
- Decisions worth preserving: a Theorem Brief using the full template in
  `../../references/BRIEF_TEMPLATE.md`.
- Decisions worth keeping forever: also `/encode` as `kind=solution` or
  `kind=decision` with the rationale.

The template is a tool, not a contract. Use only the sections the work needs.

## Routing

- SDK harness product questions → `codex-sdk-harness-product` before
  concluding.
- Redis/THG/product-state questions → `epistemic-graphrag-specialist` or
  `codex-sdk-harness-product` before locking, or handle them inline. (The
  former `redis-harness-operator` / `redis-product-safety` agents are retired
  and not installed.)
- Once decisions are resolved → `/harness mode=plan` or
  `/harness mode=execute` with the brief as input.
- If the topic is "what should I look at" rather than "what should I do" →
  `/research` for direct fractal expansion.

## Anti-Patterns

- Producing five options with similar tradeoffs to look thorough. Two real
  options beats five fake ones.
- Hiding unresolved conflict inside "recommended direction."
- Skipping repo grounding when the answer is one file away.
- Treating theorize as a permanent loop. After the brief, route to plan or
  execute.
- Inventing repo facts. If a claim is unverified, label it `Assumption`.
- Asking the user a question whose answer is in the codebase.
