# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code skill** (`openclaw-agent-studio`) that guides users through creating, optimizing, and maintaining OpenClaw Agents using the three-layer architecture (SOUL.md inner core + IDENTITY.md expression + system-prompt operations). It is a content-only project — no build system, no tests, no runtime code. All files are Markdown or shell scripts.

**Relationship to `openclaw` skill**: The `openclaw` skill covers operational tasks (install, configure, troubleshoot). This skill covers Agent **creation, optimization, and workspace maintenance** workflows exclusively. They are complementary and must not overlap.

## Installation

```bash
bash install.sh
# Creates symlink: ~/.claude/skills/openclaw-agent-studio -> ./skill/
```

After install, edits to files under `skill/` take effect immediately (symlink).

## Architecture

### Two-Layer Content Model

- **`skill/SKILL.md`** — Main entry point loaded by Claude Code. Must stay under **150 lines** to control token consumption. Contains three workflows (8-step creation + 5-step optimization + 5-step maintenance) overview and links to references.
- **`skill/references/*.md`** (8 files) — Detailed templates, specs, and checklists loaded on demand. These can be longer.

### Three-Layer Agent Architecture

The skill teaches a three-layer architecture for Agent configuration:

| Layer | File | Defines | Stability |
|-------|------|---------|-----------|
| Inner Core | SOUL.md | Personality, values, communication habits | Never changes |
| External Expression | IDENTITY.md | Name, emoji, style, catchphrase | Per scenario |
| Operations | system-prompt + AGENTS.md | Professional role, workflows, constraints, runtime context | Per task/deployment |

**Key concept — Motivation-Action Chain**: SOUL.md personality traits (WHY) drive system-prompt operational rules (HOW). Example: "Rigorous" (SOUL) → "Run full test suite before commit" (system-prompt).

### Source Documents (`docs/`)

Chinese-language source documents that the skill content was derived from. When updating skill references, check these docs for authoritative content:

- `docs/OpenClaw Agent 创建与系统提示词规范.md` — System prompt + SOUL.md spec (primary source)
- `docs/OpenClaw 动态 Agent 管理规范.md` — Dynamic management (primary source)
- `docs/OpenClaw Agent 替代创建方案.md` — ACP + Sub-agents comparison
- `docs/PRD.md` — Product requirements document

### External Dependencies (read-only references)

The skill references content from the `openclaw` skill at `~/.claude/skills/openclaw/references/`:
- `agent_runtime.md` — Bootstrap file system definition
- `multi_agent.md` — Agent registration + bindings
- `config_reference.md` — openclaw.json field reference
- `nodes.md` — Remote Node operations
- `acp_agents.md` — ACP agents
- `subagents.md` — Sub-agents

When OpenClaw docs update, corresponding references here may need updating.

## Key Conventions

- Use **SOUL.md** (uppercase), not `soul.md` — aligned with OpenClaw bootstrap file naming (AGENTS.md, TOOLS.md, etc.)
- Config examples use **JSON5** format (matching openclaw.json)
- Templates use `<placeholder>` syntax for user-replaceable values
- All templates must be wrapped in markdown code blocks for direct copy-paste
