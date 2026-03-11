---
name: openclaw-agent-create
description: Guide for creating OpenClaw Agents with SOUL.md-driven architecture, system prompts, bootstrap files, and configuration.
---

# OpenClaw Agent Creation Guide

Create and configure OpenClaw Agents using the SOUL.md-driven architecture.

## Reference Files

| File | Content |
|------|---------|
| [system-prompt-template.md](references/system-prompt-template.md) | Standard system prompt (bootstrap loader) template |
| [soul-md-spec.md](references/soul-md-spec.md) | SOUL.md writing spec and templates |
| [bootstrap-files.md](references/bootstrap-files.md) | Complete bootstrap file system (6 files) |
| [creation-checklist.md](references/creation-checklist.md) | Creation checklist + openclaw.json config template |
| [dynamic-management.md](references/dynamic-management.md) | Dynamic management, memory, cross-node migration |
| [alternative-approaches.md](references/alternative-approaches.md) | ACP agents + sub-agents reference |

## When to Activate

- User asks to create a new OpenClaw Agent
- User needs to write a system prompt for an Agent
- User wants to generate or edit SOUL.md
- User is configuring an Agent workspace or openclaw.json
- User asks about Agent creation workflow or best practices

## Agent Creation Workflow

Follow these 8 steps to create a new Agent:

### 1. Determine Execution Node

Decide where the Agent will run:
- **Local Gateway**: No Node selector needed; defaults to Gateway machine
- **Remote Node**: Configure Node selector with tags (e.g., `tags: ["m4-pro"]`); verify Node is online

### 2. Generate System Prompt (Bootstrap Loader)

Write the `instruction` field as a bootstrap loader that:
1. Detects environment (Gateway local vs Remote Node)
2. Loads SOUL.md from workspace
3. Inherits identity, goals, and tool specs
4. Adapts paths for current OS
5. Writes progress back to SOUL.md

See [system-prompt-template.md](references/system-prompt-template.md) for the standard template.

### 3. Create Workspace Directory

```bash
mkdir -p ~/.openclaw/workspace-<agent-id>
cd ~/.openclaw/workspace-<agent-id>
git init
```

### 4. Write SOUL.md

Create SOUL.md with 4 required sections:
1. **Environment Info** — Node type, OS, hardware
2. **Identity & Goals** — Role, current task
3. **Path & Tools** — Root path, pre-installed tools
4. **Constraints & Memory** — Constraints, progress notes

See [soul-md-spec.md](references/soul-md-spec.md) for full spec and examples.

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

```bash
openclaw doctor                        # System health check
openclaw agents list --bindings        # Verify registration + bindings
openclaw agent "<test prompt>"         # Test the Agent
```

## Quick Reference

### SOUL.md 4 Sections

1. **Environment Info**: Node Type, OS, Hardware Note
2. **Identity & Goals**: Role, Current Task
3. **Path & Tools**: Root Path, Pre-installed Tools
4. **Constraints & Memory**: Memory entries, Constraint rules

### Bootstrap File Checklist

- [ ] SOUL.md (required)
- [ ] AGENTS.md (recommended)
- [ ] TOOLS.md (recommended)
- [ ] BOOTSTRAP.md (optional)
- [ ] IDENTITY.md (optional)
- [ ] USER.md (optional)

### 5-Step Core Mechanism

1. **Detect** — Identify Gateway local vs Remote Node environment
2. **Bootstrap** — Load SOUL.md via `list_files` / `read_file`
3. **Awaken** — Inherit identity, goals, tool specs from SOUL.md
4. **Adapt** — Adjust paths and tool chains for current OS
5. **Write Back** — Persist progress to SOUL.md or memory files

## Alternative Approaches

For lightweight or specialized use cases, consider:
- **ACP Agents**: External runtimes (Codex, Claude Code, Gemini CLI) via ACP protocol
- **Sub-agents**: Internal nested sessions for parallel tasks

See [alternative-approaches.md](references/alternative-approaches.md) for details.
