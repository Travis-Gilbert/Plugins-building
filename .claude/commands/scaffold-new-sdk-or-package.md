---
name: scaffold-new-sdk-or-package
description: Workflow command scaffold for scaffold-new-sdk-or-package in claude-marketplace.
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /scaffold-new-sdk-or-package

Use this workflow when working on **scaffold-new-sdk-or-package** in `claude-marketplace`.

## Goal

Creates the initial structure for a new SDK or package, including config, source, and test files.

## Common Files

- `*/.gitignore`
- `*/pyproject.toml`
- `*/package.json`
- `*/src/*.ts`
- `*/theorem_context/*.py`
- `*/tests/*.py`

## Suggested Sequence

1. Understand the current state and failure mode before editing.
2. Make the smallest coherent change that satisfies the workflow goal.
3. Run the most relevant verification for touched files.
4. Summarize what changed and what still needs review.

## Typical Commit Signals

- Add .gitignore and project config (e.g., pyproject.toml, package.json).
- Create source code directory and initial __init__.py or index.ts.
- Add test directory with at least one test file.
- Add README.md for documentation.

## Notes

- Treat this as a scaffold, not a hard-coded script.
- Update the command if the workflow evolves materially.