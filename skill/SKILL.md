---
name: openclaw-agent-studio
description: Guide for creating, optimizing, and maintaining OpenClaw Agents — SOUL.md-driven architecture, system prompts, bootstrap files, workspace token budget, memory distillation, and configuration.
---

# OpenClaw Agent Studio Guide

Create, optimize, and maintain OpenClaw Agents using the SOUL.md-driven architecture.

## Reference Files

| File | Content |
|------|---------|
| [system-prompt-template.md](references/system-prompt-template.md) | Standard system prompt (bootstrap loader) template |
| [soul-md-spec.md](references/soul-md-spec.md) | SOUL.md writing spec and templates |
| [bootstrap-files.md](references/bootstrap-files.md) | Complete bootstrap + workspace file system (11 files) |
| [creation-checklist.md](references/creation-checklist.md) | Creation checklist + openclaw.json config template |
| [dynamic-management.md](references/dynamic-management.md) | Dynamic management, memory, cross-node migration |
| [alternative-approaches.md](references/alternative-approaches.md) | ACP agents + sub-agents reference |
| [optimization-guide.md](references/optimization-guide.md) | Audit and optimize existing Agents |
| [workspace-maintenance.md](references/workspace-maintenance.md) | Token budget, redundancy audit, memory distillation |

## When to Activate

- User asks to create a new OpenClaw Agent
- User needs to write a system prompt for an Agent
- User wants to generate or edit SOUL.md
- User is configuring an Agent workspace or openclaw.json
- User asks about Agent creation workflow or best practices
- User wants to audit, review, or optimize an existing Agent
- User asks to check an Agent against documentation or best practices
- User wants to fix or improve an Agent that is not working correctly
- User wants to audit workspace token budget or reduce bloat
- User wants to run memory distillation on daily logs
- User wants to check workspace files for redundancy or staleness

## Agent Creation Workflow

Follow these 8 steps to create a new Agent:

### 1. Determine Execution Node

- **Local Gateway**: No Node selector needed; defaults to Gateway machine
- **Remote Node**: Configure Node selector with tags (e.g., `tags: ["m4-pro"]`); verify Node is online

### 2. Generate System Prompt (Bootstrap Loader)

Write the `instruction` field as a bootstrap loader (5-step: Detect → Load SOUL.md → Inherit identity → Adapt paths → Write back). See [system-prompt-template.md](references/system-prompt-template.md).

### 3. Create Workspace Directory

`mkdir -p ~/.openclaw/workspace-<agent-id> && cd $_ && git init`

### 4. Write SOUL.md

Create SOUL.md with 4 sections: (1) Environment Info, (2) Identity & Goals, (3) Path & Tools, (4) Constraints & Memory. See [soul-md-spec.md](references/soul-md-spec.md) for full spec and examples.

### 5. Generate Bootstrap Files

Create the complete bootstrap file set:

| File | Required | Purpose |
|------|----------|---------|
| SOUL.md | Yes | Persona + environment awareness |
| AGENTS.md | Recommended | Operating instructions + memory |
| TOOLS.md | Recommended | Tool usage notes |
| BOOTSTRAP.md | Optional | First-run ritual (auto-deleted) |
| IDENTITY.md | Optional | Name, style, emoji |
| USER.md | Optional | User profile + preferences |

See [bootstrap-files.md](references/bootstrap-files.md) for templates.

### 6. Configure Permissions

Grant required tools: `read_file`, `write_file`, `execute_command`, `list_files`.

### 7. Register in openclaw.json

Add Agent to `agents.list` and configure `bindings`:

```json5
{
  agents: {
    list: [{ id: "<agent-id>", workspace: "~/.openclaw/workspace-<agent-id>" }],
  },
  bindings: [
    { agentId: "<agent-id>", match: { channel: "<channel>", accountId: "<account>" } },
  ],
}
```

See [creation-checklist.md](references/creation-checklist.md) for full config template.

### 8. Verify

Run `openclaw doctor`, `openclaw agents list --bindings`, and `openclaw agent "<test prompt>"`.

## Agent Optimization Workflow

Follow these 5 steps to audit and optimize an existing Agent:

### 1. Audit

Collect the Agent's current state: workspace files, SOUL.md content, openclaw.json config, and git history.

### 2. Analyze

Run gap analysis against spec checklists:
- **SOUL.md**: 4 sections complete? Fields accurate? Memory/Constraints populated?
- **System Prompt**: Uses bootstrap loader pattern? All 5 steps present?
- **Bootstrap Files**: Required files exist? Content follows templates?
- **Configuration**: agents.list entry correct? Workspace path valid? Bindings set?

### 3. Report

Generate a structured findings report with severity levels:
- **Critical**: Agent cannot function (missing SOUL.md, broken config path)
- **High**: Core feature degraded (no bootstrap loader, missing AGENTS.md)
- **Medium**: Best practice not followed (no constraints, missing TOOLS.md)
- **Low**: Enhancement opportunity (no IDENTITY.md, no git init)

### 4. Fix

Apply fixes using the 7 common optimization patterns:
1. Empty SOUL.md → Generate complete 4-section file
2. Hardcoded system prompt → Replace with bootstrap loader
3. Missing AGENTS.md → Create with directives + task queue
4. Stale memory → Archive old entries, refresh current task
5. Missing constraints → Add role-appropriate boundaries
6. Path mismatch → Align workspace, config, and SOUL.md paths
7. No git → Initialize recording layer

### 5. Verify

Run `openclaw doctor`, test Agent identity and constraints, confirm git tracks changes.

See [optimization-guide.md](references/optimization-guide.md) for detailed checklists, report template, and pattern descriptions.

## Workspace Maintenance Workflow

Day-to-day workspace health — keep files lean, non-redundant, and within token budget.

1. **Token Budget Audit** — Flag files over 10k chars; fix immediately if over 20k (truncated). Target: <80k total for auto-loaded files.
2. **Redundancy Check** — Cross-check SOUL.md vs AGENTS.md, TOOLS.md vs MEMORY.md, AGENTS.md vs docs/. Remove duplicates.
3. **Staleness Review** — Dead SSH hosts, completed tasks, changed preferences, obsolete env info.
4. **Memory Distillation** — Promote daily logs → MEMORY.md. Demote stable rules → skill docs. Archive logs >30 days.
5. **Offload to docs/** — Move long narrative and historical context out of bootstrap files.

See [workspace-maintenance.md](references/workspace-maintenance.md) for audit commands, redundancy matrix, and distillation process.
