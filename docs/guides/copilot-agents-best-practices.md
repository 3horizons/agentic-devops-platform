# Best Practices for Working with GitHub Copilot Agents
_A practical playbook for Agent Mode (IDE), Copilot Coding Agent (GitHub), Copilot CLI, Custom Agents, Skills, MCP, scripts, and integrations._

---

## 1) Mental model: agents are “junior teammates with superpowers”
Agents can do a lot on your behalf (read code, edit files, run tests, open PRs), but they still need **clear scope, constraints, and verification**. Your job shifts from “typing code” to:

- **Decomposing work** into finishable tasks  
- **Providing guardrails** (commands, file boundaries, constraints)  
- **Reviewing outputs** (diffs, logs, tests, security)  
- **Iterating** quickly when drift appears

---

## 2) Pick the right agentic surface for the job
Use the right tool to reduce friction and risk.

### Agent mode (IDE: VS Code / JetBrains / etc.)
Best for **synchronous** work: you iterate rapidly, run commands locally, and adjust intent in real time.

Use it when:
- You’re exploring or refactoring with high uncertainty
- You want to drive design and implementation together
- You need tight feedback loops (run tests, inspect errors, repeat)

### Copilot Coding Agent (GitHub)
Best for **asynchronous** work: hand off a task and get a PR back.

Use it when:
- The task has clear “Definition of Done”
- It’s low-to-medium complexity and can be validated by tests/lint
- You want GitHub-native workflow automation (branch + commits + PR)

### Copilot CLI (terminal)
Best for **command-heavy** workflows: triage, debugging, ops, scaffolding, automation scripts.

Use it when:
- Your workflow lives in the terminal (containers, servers, CI/CD)
- You want to run multi-step tasks via plan/agentic execution
- You want to integrate agentic behavior into scripts and automations

---

## 3) Task design: make work “agent-finishable”
Most agent failures are **scope failures**, not “model failures”.

### 3.1 Scope rules (non-negotiables)
- **One task, one outcome.** Avoid “refactor everything” requests.
- **Explicit acceptance criteria.** Make “done” measurable.
- **List commands to validate.** Tests, lint, formatting, build.
- **Define file boundaries.** What can be changed vs. read-only.
- **Call out constraints.** Performance, backward compatibility, security, API contracts.
- **Provide examples.** “Do it like this existing file” is gold.

### 3.2 Provide context that prevents guesswork
Include:
- Repro steps, error logs, screenshots
- Links to internal docs/specs
- Similar code paths to copy
- Non-obvious project conventions (naming, folder structure, style)

### 3.3 Avoid merge conflicts in parallel agent runs
If you plan to run many tasks concurrently:
- Split by **module/component** (avoid same files)
- Prefer **research/analysis/docs** tasks in parallel
- Keep dependent tasks **sequential**

---

## 4) A “golden” task template for Coding Agent (copy/paste)
Use this for GitHub Issues or Mission Control prompts.

```markdown
## Goal
<one sentence>

## Context
- What is happening today?
- Why does it matter?
- Links: <design doc / issue / prior PR>

## Scope
✅ In scope:
- <bullets>

🚫 Out of scope:
- <bullets>

## Constraints
- Compatibility: <versions / APIs>
- Performance: <limits>
- Security/privacy: <requirements>

## Implementation notes
- Files to inspect: <paths>
- Patterns to follow: <links to existing code>
- Do NOT modify: <paths/folders>

## Validation
Run:
- <command>
- <command>

## Acceptance criteria
- [ ] <checkbox>
- [ ] <checkbox>

## Deliverable
- PR includes: <tests/docs/notes>
```

---

## 5) Instruction layers: keep “rules” separate from “procedures”
You will typically have **three** complementary instruction mechanisms:

1. **Repository / path instructions** (broad rules, conventions)  
2. **Custom agent profiles** (persona + tool access + boundaries)  
3. **Skills** (repeatable procedures + scripts/resources)

### 5.1 Recommended repo scaffolding
```text
.github/
  copilot-instructions.md
  instructions/
    backend.instructions.md
    docs.instructions.md
  agents/
    docs-agent.agent.md
    test-agent.agent.md
    lint-agent.agent.md
  skills/
    github-actions-failure-debugging/
      SKILL.md
      scripts/
        analyze_logs.py
  workflows/
    copilot-setup-steps.yml
AGENTS.md
```

Notes:
- Keep instruction files **short, specific, and example-driven**.
- Prefer **path-scoped instructions** for directories that differ (backend vs frontend).
- Use **AGENTS.md** as an “agent playbook” file when you want the agent to auto-load repo conventions.

---

## 6) Custom agents: build a “team of specialists”
The most reliable pattern is: **one agent per job**.

Examples:
- `docs-agent`: only writes to docs
- `test-agent`: adds/updates tests
- `lint-agent`: fixes formatting/lint without changing logic
- `security-agent`: scans for obvious security issues, secrets, risky patterns

### 6.1 Design rules for custom agents
- **Define a single responsibility.** Don’t create “general helper” agents.
- **Put commands early** (test, build, lint, format). Include real flags.
- **Prefer code examples over prose.** Show the style you want.
- **Three-tier boundaries:**  
  - ✅ Always do  
  - ⚠️ Ask first  
  - 🚫 Never do
- **Least-privilege tools.** Give only what’s needed:
  - Planning/research agent: read/search only
  - Coding agent: edit + run + test
  - Docs agent: write docs + markdown lint
- **Use `target` if you need environment-specific agents** (IDE-only vs GitHub-only).
- **Use `handoffs` to chain specialist agents** for multi-step workflows.

### 6.2 Custom agent profile template (Markdown + YAML frontmatter)
> Create agent profiles in `.github/agents/`. In IDEs, the UI creates `.agent.md` files for you.

```markdown
---
name: docs_agent
description: Expert technical writer for this project
# model: <choose a model in your environment>
# target: github-copilot | vscode
# tools:
#   - read
#   - edit
#   - bash
# handoffs:
#   - test_agent
---

## Role
You are an expert technical writer for this repository.

## Project knowledge
- Tech stack: <versions>
- Write to: `docs/`
- Read from: `src/`
- Never modify: `src/`, `infra/`, `*.secrets.*`

## Commands
- Build docs: `npm run docs:build`
- Lint markdown: `npx markdownlint docs/`

## Boundaries
- ✅ Always: follow existing docs style; validate links; keep examples runnable
- ⚠️ Ask first: major reorganization of docs structure
- 🚫 Never: modify source code; change CI; add secrets; change release config
```

---

## 7) Skills: reusable procedures + scripts (SKILL.md)
**Agent Skills** are “packages” of instructions, scripts, and resources that agents can load when relevant.

### 7.1 When to use skills vs. custom agents
Use **skills** when you want:
- A repeatable **procedure** (“debug GitHub Actions failures”, “generate changelog”, “triage incident”)
- Optional **scripts/resources** co-located with instructions
- A shared workflow used across many repos or teams

Use **custom agents** when you want:
- A persona + default boundaries
- A fixed toolchain and consistent behavior for a type of task

### 7.2 Skill structure
- Each skill gets its own directory
- Directory name: lowercase, hyphen-separated, matches the skill name
- The skill instruction file is **always** `SKILL.md` and uses YAML frontmatter

### 7.3 Skill template
```markdown
---
name: github-actions-failure-debugging
description: Guide for debugging failing GitHub Actions workflows.
---

## When to use
Use when a GitHub Actions workflow fails and you need to identify root cause and propose a fix.

## Inputs to collect
- Workflow run URL
- Job name + step name that failed
- Logs (copy/paste relevant part)
- Recent commits/PRs related to CI

## Procedure
1. Identify failing workflow/job/step.
2. Classify failure: dependency, secrets/permissions, flaky test, environment, lint/typecheck.
3. Reproduce locally if possible (or via minimal script).
4. Propose the smallest fix that makes the pipeline green.
5. Add/adjust tests to prevent regression.

## Commands
- `gh run view <id> --log` (if available)
- `npm test` / `pytest -v` / `cargo test` (repo-specific)

## Output format
Return:
- Root cause summary (2–3 bullets)
- Proposed fix (diff or file list)
- Validation steps (commands + expected result)
```

---

## 8) MCP: extend agents safely with tools
**Model Context Protocol (MCP)** enables agents to access tools and external context (files, APIs, browsers, databases).

### 8.1 Practical MCP guardrails
- **Enable only what you need.** Avoid “allow all tools” by default.
- **Prefer read-only tools** for discovery/planning.
- **Treat tool output as untrusted input.** Validate formats, handle errors, sanitize.
- **Never place secrets in prompts or tool configs.** Use GitHub-native secret mechanisms.
- **Document tool usage** in your agent profile or skill:
  - When to call the tool
  - Expected inputs/outputs
  - Failure modes and retries
- **Keep network access tight.** If the environment is firewalled, plan for allowlists and offline fallbacks.

### 8.2 Default vs custom MCP servers
- Many workflows benefit from built-in GitHub and browser/testing tools (e.g., Playwright).
- Add custom MCP servers when you need:
  - Ticketing systems
  - Internal APIs
  - Databases
  - Cloud consoles (via secure proxies)

---

## 9) Scripts and automation: make “validation” one command away
Agents succeed when validation is **fast, deterministic, and documented**.

### 9.1 Script design best practices
- Non-interactive (no prompts)
- Deterministic (same input → same output)
- Clear exit codes
- Verbose logs in CI context
- Idempotent (safe to re-run)

### 9.2 Make project commands discoverable
Put the real commands in:
- `AGENTS.md` / repo instructions
- Custom agent profiles (commands section)
- Skills (commands section)
- `Makefile` / `package.json` scripts / `taskfile.yml`

### 9.3 Pre-install dependencies for Coding Agent
If Coding Agent runs in an ephemeral environment, define setup steps (e.g., `copilot-setup-steps.yml`) to install dependencies and required tooling up front.

---

## 10) Orchestration: Mission Control / Agents panel best practices
When running multiple Coding Agent tasks:

### 10.1 Parallelize what’s safe
Good parallel tasks:
- Docs generation
- Security review
- Research/analysis
- Work in separate modules/components

Avoid parallel tasks when:
- They touch the same files
- One depends on the other
- You’re still discovering the root cause

### 10.2 Watch for “drift signals”
Intervene early if you see:
- Repeated failing tests without strategy change
- Unexpected files created
- Scope creep (“I refactored the whole subsystem”)
- Misread intent (seen in logs)
- Circular behavior

### 10.3 Steering patterns
Bad steering: “This doesn’t look right.”  
Good steering: “Don’t modify `db.js` (shared). Add config in `api/config/db-pool.js` so the change stays isolated.”

---

## 11) Review checklist (required for every agent PR)
1. **Session logs** (intent before code)  
2. **Files changed** (unexpected changes, risky paths)  
3. **Checks** (unit tests, Playwright, CI/CD, lint/typecheck)  
4. **Security** (secrets, auth flows, permissions, dependency changes)  
5. **Maintainability** (style, naming, docs, edge cases)

Bonus: Ask the agent to self-review:
- “What edge cases are missing?”
- “What test coverage is incomplete?”
- “If a check fails, what’s the most likely root cause?”

---

## 12) Spec-first prompting (for complex work)
For large or high-risk changes, start with a **spec**:
- Define desired behavior, invariants, and interfaces
- List acceptance criteria and constraints
- Break work into incremental phases with validation gates

This reduces ambiguity and makes agent execution more predictable.

---

## 13) Curated resource links (as provided)
```text
https://docs.github.com/en/copilot/tutorials/coding-agent/get-the-best-results
https://docs.github.com/en/copilot/get-started/best-practices
https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/
https://github.blog/ai-and-ml/github-copilot/how-to-maximize-github-copilots-agentic-capabilities/
https://github.blog/ai-and-ml/github-copilot/github-copilot-coding-agent-101-getting-started-with-agentic-workflows-on-github/
https://github.blog/ai-and-ml/github-copilot/power-agentic-workflows-in-your-terminal-with-github-copilot-cli/
https://github.blog/ai-and-ml/github-copilot/how-to-orchestrate-agents-using-mission-control/
https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents
https://docs.github.com/en/copilot/concepts/agents/about-agent-skills
https://docs.github.com/en/copilot/concepts/agents/copilot-memory
https://docs.github.com/en/copilot/concepts/tools/about-copilot-integrations
https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents
https://docs.github.com/en/copilot/concepts/agents/coding-agent/agent-management
https://docs.github.com/en/copilot/concepts/agents/about-copilot-cli
https://github.com/mcp?locale=en-US
https://github.com/github/awesome-copilot
https://github.com/github/spec-kit/tree/main
https://github.com/microsoft/GitHub-Copilot-for-Azure
https://github.com/skills/ai-in-actions
https://github.com/githubnext/agentics
https://code.visualstudio.com/docs/copilot/agents/agents-tutorial
https://techcommunity.microsoft.com/blog/azuredevcommunityblog/building-agents-with-github-copilot-sdk-a-practical-guide-to-automated-tech-upda/4488948
```
