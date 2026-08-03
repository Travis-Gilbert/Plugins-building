---
name: add-new-agent-or-skill
description: Workflow command scaffold for add-new-agent-or-skill in claude-marketplace.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /add-new-agent-or-skill

Use this workflow when working on **add-new-agent-or-skill** in `claude-marketplace`.

## Goal

Adds a new agent or skill to a plugin/module, including its definition and sometimes associated references or manifests.

## Common Files

- `*/agents/*.md`
- `*/skills/*/SKILL.md`
- `*/references/*.md`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Create or update one or more agent markdown files in agents/.
- Create or update SKILL.md files in skills/.
- Optionally update references/ (e.g., PLUGIN_INVENTORY.md, ROUTING.md) to document or register the new agent/skill.

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.