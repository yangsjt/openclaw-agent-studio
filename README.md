# openclaw-agent-studio

A [Claude Code](https://claude.ai/code) skill for creating, optimizing, and maintaining [OpenClaw](https://github.com/nicepkg/openclaw) Agents using the SOUL.md-driven architecture.

## What It Does

This skill provides three guided workflows covering the full Agent lifecycle:

| Workflow | Steps | What It Covers |
|----------|-------|----------------|
| **Agent Creation** | 8 steps | System prompt, SOUL.md, bootstrap files, config, verification |
| **Agent Optimization** | 5 steps | Audit, gap analysis, severity report, 7 fix patterns, verification |
| **Workspace Maintenance** | 5 steps | Token budget, redundancy audit, memory distillation, staleness review |

## Installation

```bash
bash install.sh
```

This creates a symlink from `~/.claude/skills/openclaw-agent-studio` to the `skill/` directory. Edits to skill files take effect immediately.

## Usage

Once installed, the skill activates automatically in Claude Code when you:

- Ask to create a new OpenClaw Agent
- Want to write or edit SOUL.md / system prompts
- Need to audit or optimize an existing Agent
- Want to check workspace token budget or run memory distillation

Example prompts:

```
Create a new OpenClaw Agent for home automation on my Mac mini
Audit and optimize my existing coding agent
Check my workspace files for bloat and redundancy
```

## Project Structure

```
openclaw-agent-studio/
├── skill/
│   ├── SKILL.md                              # Main entry point (< 150 lines)
│   └── references/
│       ├── system-prompt-template.md          # Bootstrap loader template
│       ├── soul-md-spec.md                    # SOUL.md writing spec
│       ├── bootstrap-files.md                 # 11 workspace file types
│       ├── creation-checklist.md              # Creation checklist + config
│       ├── dynamic-management.md              # Memory, migration, lifecycle
│       ├── alternative-approaches.md          # ACP agents + sub-agents
│       ├── optimization-guide.md              # Audit checklists + fix patterns
│       └── workspace-maintenance.md           # Token budget + distillation
├── docs/                                      # Chinese source documents
├── install.sh                                 # Symlink installer
└── CLAUDE.md                                  # Project instructions for Claude Code
```

## Relationship to Other Skills

| Skill | Scope |
|-------|-------|
| **openclaw** | Install, configure, troubleshoot OpenClaw (operations) |
| **openclaw-agent-studio** | Create, optimize, maintain Agents (development) |

The two skills are complementary and do not overlap.

## License

MIT
