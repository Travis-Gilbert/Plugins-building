```markdown
# claude-marketplace Development Patterns

> Auto-generated skill from repository analysis

## Overview

This skill teaches you the core development patterns, coding conventions, and collaborative workflows used in the `claude-marketplace` JavaScript codebase. You'll learn how to structure code, write and test features, manage agents and skills, and document or refactor the project according to established standards. The repository favors clear organization, conventional commits, and a modular, test-driven approach.

---

## Coding Conventions

**File Naming**
- Use `camelCase` for file names.
  - Example: `myHelperFunction.js`

**Import Style**
- Use relative imports.
  - Example:
    ```js
    const utils = require('./utils');
    ```

**Export Style**
- Mixed: both CommonJS (`module.exports`) and ES module (`export`) styles may be present.
  - Example (CommonJS):
    ```js
    module.exports = myFunction;
    ```
  - Example (ES module):
    ```js
    export default myFunction;
    ```

**Commit Messages**
- Use [Conventional Commits](https://www.conventionalcommits.org/):
  - Prefixes: `feat`, `chore`, `fix`, `docs`, `refactor`
  - Example:
    ```
    feat: add support for new agent registration
    ```

---

## Workflows

### Add New Agent or Skill
**Trigger:** When you want to introduce a new agent or skill to a plugin/module.  
**Command:** `/add-agent-skill`

1. Create or update agent markdown files in `agents/`.
2. Create or update `SKILL.md` files in `skills/`.
3. Optionally update references (e.g., `PLUGIN_INVENTORY.md`, `ROUTING.md`) to document or register the new agent/skill.

**Example:**
```bash
# Add a new agent
touch agents/myNewAgent.md

# Document a new skill
mkdir -p skills/myNewSkill
touch skills/myNewSkill/SKILL.md
```

---

### Scaffold New SDK or Package
**Trigger:** When starting a new SDK or package (Python or TypeScript).  
**Command:** `/scaffold-sdk`

1. Add `.gitignore` and project config (e.g., `package.json`).
2. Create source code directory and initial entry file (e.g., `index.ts`).
3. Add a test directory with at least one test file.
4. Add `README.md` for documentation.

**Example:**
```bash
npm init -y
touch .gitignore
mkdir src
touch src/index.ts
mkdir tests
touch tests/index.test.ts
touch README.md
```

---

### Implement Feature with Tests
**Trigger:** When adding a new feature or helper function, ensuring it is tested.  
**Command:** `/feature-with-tests`

1. Add or update a source file (e.g., `helpers.js`).
2. Add or update a corresponding test file (e.g., `helpers.test.js`).
3. Optionally add fixtures or sample data for testing.

**Example:**
```js
// helpers.js
function add(a, b) { return a + b; }
module.exports = { add };

// helpers.test.js
const { add } = require('./helpers');
test('adds numbers', () => {
  expect(add(2, 3)).toBe(5);
});
```

---

### Refactor or Remove Obsolete Agents/Skills
**Trigger:** When agents or skills are no longer needed due to architectural changes.  
**Command:** `/remove-obsolete-agents-skills`

1. Delete agent markdown files from `agents/`.
2. Delete `SKILL.md` and related files from `lib/` or `skills/`.
3. Remove associated scripts or knowledge files if no longer referenced.

**Example:**
```bash
rm agents/oldAgent.md
rm -r skills/oldSkill/
```

---

### Update SDK or Package Structure
**Trigger:** When SDK/package naming or structure needs to be aligned across the codebase.  
**Command:** `/sync-sdk-structure`

1. Update `README.md` and config files (`package.json`).
2. Rename or update source files and directories as needed.
3. Update test files to match the new structure.
4. Update documentation (e.g., `AGENTS.md`) to reflect changes.

---

### Document Design and Implementation Plan
**Trigger:** When planning or documenting a new architecture or major feature.  
**Command:** `/add-design-doc`

1. Add or update a markdown file in `docs/plans/` describing the design or implementation plan.
2. Reference the design doc in related commit messages and documentation.

**Example:**
```bash
mkdir -p docs/plans
touch docs/plans/new-feature-plan.md
```

---

## Testing Patterns

- **Framework:** [Jest](https://jestjs.io/)
- **Test File Pattern:** `*.test.js`
- **Test Example:**
  ```js
  // sum.js
  function sum(a, b) { return a + b; }
  module.exports = sum;

  // sum.test.js
  const sum = require('./sum');
  test('adds 1 + 2 to equal 3', () => {
    expect(sum(1, 2)).toBe(3);
  });
  ```

- Place tests alongside or in a dedicated `tests/` directory.
- Use fixtures or sample data as needed for comprehensive testing.

---

## Commands

| Command                        | Purpose                                                      |
|---------------------------------|--------------------------------------------------------------|
| /add-agent-skill                | Add a new agent or skill, and update documentation           |
| /scaffold-sdk                   | Scaffold a new SDK or package structure                      |
| /feature-with-tests             | Implement a new feature/module with corresponding tests      |
| /remove-obsolete-agents-skills  | Remove obsolete agents, skills, and related files            |
| /sync-sdk-structure             | Synchronize or migrate SDK/package structure and naming      |
| /add-design-doc                 | Add or update a design/implementation plan in documentation  |
```
