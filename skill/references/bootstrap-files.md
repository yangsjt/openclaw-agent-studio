# Bootstrap Files System

OpenClaw injects bootstrap files into the Agent workspace (`agents.defaults.workspace`) during setup. These files define the Agent's personality, instructions, tools, and user context.

## File Overview

| File | Purpose | Required | Loaded |
|------|---------|----------|--------|
| `SOUL.md` | Inner core — personality, values, communication habits | **Required** | Every turn (all agents) |
| `AGENTS.md` | Runtime context + operating instructions + task queue | Recommended | Every turn (all agents) |
| `TOOLS.md` | Environment-specific tool/device notes | Recommended | Every turn (all agents) |
| `IDENTITY.md` | External expression — name, style, emoji, catchphrase | Recommended | Every turn |
| `BOOTSTRAP.md` | One-time first-run ritual (auto-deleted) | Optional | New workspaces only |
| `USER.md` | User profile + preferred address | Optional | Every turn (all agents) |
| `HEARTBEAT.md` | Periodic check tasks and health routines | Optional | Heartbeat turns only |
| `BOOT.md` | Startup actions (requires `hooks.internal.enabled`) | Optional | On gateway startup |
| `MEMORY.md` | Long-term curated facts and iron-law rules | Optional | Main sessions only (NEVER in groups) |
| `memory/YYYY-MM-DD.md` | Daily session logs | Optional | Per boot sequence |
| `checklists/*.md` | Step-by-step ops guides | Optional | On demand |

These files are created by `openclaw setup` and can be manually edited at any time.

To skip bootstrap file injection: `{ agent: { skipBootstrap: true } }`.

## Three-Layer Architecture

```
SOUL.md (Inner Core — personality, values, communication. Unchanging.)
  │
  ├── IDENTITY.md (External Expression — SOUL's outward presentation. Adjustable per scenario.)
  │
  ├── AGENTS.md (Runtime Context + Operating Instructions)
  │     ├── TOOLS.md (tool usage details)
  │     └── MEMORY.md (long-term memory)
  │
  └── system-prompt (Bootstrap + Professional Capability Definition)
        └── USER.md (user preferences)
```

### Layer Responsibilities

| Layer | File(s) | Defines | Changes when... |
|-------|---------|---------|-----------------|
| **Inner Core** | SOUL.md | WHO the Agent is — personality, values, habits | Never (the soul is constant) |
| **External Expression** | IDENTITY.md | How others see the Agent — name, emoji, style | Scenario changes (dev vs. support mode) |
| **Operations** | AGENTS.md + system-prompt | WHAT the Agent does and HOW | Task, environment, or deployment changes |

### Key Relationships

- **SOUL.md** is the foundation — defines the Agent's character and decision-making compass
- **IDENTITY.md** extends SOUL.md — same personality expressed through different names, styles, and catchphrases
- **AGENTS.md** contains runtime context (environment, tools, paths) and operational instructions
- **system-prompt** bootstraps the Agent and defines professional role, workflows, and constraints
- **SOUL.md drives system-prompt** via the motivation-action chain (personality traits → operational rules)

## File Templates

### SOUL.md (Required)

See [soul-md-spec.md](soul-md-spec.md) for the full specification and examples.

### AGENTS.md (Recommended)

```markdown
# Agent Operating Instructions

## 1. Runtime Context
- **Node Type**: <Local Gateway / Remote Node>
- **OS**: <e.g., macOS Sequoia 15.3 / Ubuntu 24.04>
- **Working Directory**: <absolute path to workspace>
- **Toolchain**: <e.g., git, nodejs v22, bun 1.2, docker>
- **Hardware Note**: <e.g., M4 Pro, 64GB RAM>

## 2. Primary Directives
- <core behavior directive 1>
- <core behavior directive 2>

## 3. Task Queue
1. <current priority task>
2. <next task>

## 4. Response Guidelines
- <how to format responses>
- <when to ask for clarification>
- <escalation rules>

## 5. Memory Log
- <date>: <key decision or progress note>
- <date>: <important context for future sessions>

### Environment Self-Healing Log
- <date>: <discovered issue and resolution>
```

**Purpose**: AGENTS.md serves as the Agent's "operating manual on the ground" — it provides runtime context (where am I, what tools do I have) and operational instructions (what to do, how to do it). The Memory Log section acts as persistent memory across sessions.

**What moved here**: Runtime Context (§1) now contains environment information that was previously in SOUL.md (Node Type, OS, hardware, paths, tools). This separation ensures environment-specific details change with deployment, while personality remains constant.

**Example** (Coding Agent):

```markdown
# Agent Operating Instructions

## 1. Runtime Context
- **Node Type**: Remote Node
- **OS**: macOS Sequoia 15.3
- **Working Directory**: /Users/dev/workspaces/myapp
- **Toolchain**: git, nodejs v22, bun 1.2, docker, postgresql 16
- **Hardware Note**: M4 Pro, 64GB RAM, 1TB SSD

## 2. Primary Directives
- Follow TDD: write tests first, then implement
- Use conventional commits for all git operations
- Run linter and type checker before committing

## 3. Task Queue
1. Complete user authentication module (OAuth2 + JWT)
2. Add rate limiting to API endpoints
3. Write integration tests for payment flow

## 4. Response Guidelines
- When given a bug report, reproduce first, then fix
- For architectural decisions, present 2-3 options with trade-offs
- Commit only when explicitly asked

## 5. Memory Log
- 2026-03-01: Decided on Drizzle ORM over Prisma for type safety
- 2026-03-05: Auth flow uses PKCE code flow, approved by user
- 2026-03-10: Database migration for users table completed

### Environment Self-Healing Log
- 2026-03-01: bun not found on initial setup, installed via `curl -fsSL https://bun.sh/install | bash`
- 2026-03-05: postgresql service not running, started with `brew services start postgresql@16`
```

### TOOLS.md (Recommended)

```markdown
# Tool Usage Notes

## <tool-name>
- **Purpose**: <what this tool does>
- **Usage**: <how to invoke it>
- **Notes**: <caveats, version requirements, special flags>

## <tool-name>
- **Purpose**: <what this tool does>
- **Usage**: <how to invoke it>
- **Notes**: <caveats, version requirements, special flags>
```

**Purpose**: TOOLS.md documents tools available in the workspace that the Agent might need to use, especially non-standard or custom tools.

**Example**:

```markdown
# Tool Usage Notes

## bun
- **Purpose**: JavaScript runtime and package manager
- **Usage**: `bun run <script>`, `bun install`, `bun test`
- **Notes**: Preferred over npm/yarn in this workspace. v1.2+.

## Drizzle Kit
- **Purpose**: Database migration tool
- **Usage**: `bunx drizzle-kit generate`, `bunx drizzle-kit push`
- **Notes**: Config at `drizzle.config.ts`. Always use `generate` then review before `push`.

## sag (Search and Grep)
- **Purpose**: Fast codebase search
- **Usage**: `sag "pattern"` or `sag -t typescript "pattern"`
- **Notes**: Custom alias, wrapper around ripgrep with project-specific ignores.
```

### IDENTITY.md (Recommended)

```markdown
# Agent Identity

- **Name**: <display name>
- **Emoji**: <representative emoji>
- **Style**: <external presentation style, e.g., professional and concise, uses Simplified Chinese>
- **Catchphrase**: <signature phrase>
```

**Purpose**: IDENTITY.md is the **external expression layer** of SOUL.md — it defines how the Agent presents itself to others. The same SOUL (personality core) can be paired with different IDENTITYs depending on the scenario (e.g., professional style for dev work, warm style for customer support).

**Relationship to SOUL.md**: SOUL.md defines inner traits ("patient, rigorous, curious"); IDENTITY.md defines outward expression ("named Atlas, uses technical language, catchphrase: Let me map that out"). Think of it as the same person wearing different outfits.

**Example**:

```markdown
# Agent Identity

- **Name**: Atlas
- **Emoji**: :globe_with_meridians:
- **Style**: Professional but approachable. Uses technical terms precisely but explains them when context suggests the audience may not be familiar.
- **Catchphrase**: "Let me map that out for you."
```

### BOOTSTRAP.md (Optional)

```markdown
# First-Run Bootstrap

Complete these setup steps on first activation, then delete this file.

## Steps
1. [ ] Verify all tools listed in AGENTS.md Runtime Context are installed
2. [ ] Run `git status` to confirm workspace is clean
3. [ ] Read SOUL.md and confirm personality is internalized
4. [ ] <project-specific setup step>
5. [ ] <project-specific setup step>

## On Completion
Delete this file after all steps are verified.
```

**Purpose**: BOOTSTRAP.md defines a one-time setup ritual. The Agent executes these steps on its first run, then deletes the file. This is useful for initial workspace verification, dependency installation, or configuration checks.

### USER.md (Optional)

```markdown
# User Profile

- **Name**: <user's preferred name>
- **Preferred Address**: <how to address the user>
- **Timezone**: <user's timezone>
- **Language**: <preferred language>
- **Communication Preferences**:
  - <preference 1>
  - <preference 2>
```

**Example**:

```markdown
# User Profile

- **Name**: Alex Chen
- **Preferred Address**: Alex
- **Timezone**: Asia/Shanghai (UTC+8)
- **Language**: Chinese (primary), English (technical discussions)
- **Communication Preferences**:
  - Prefers concise answers, expand only when asked
  - Technical discussions in English, casual chat in Chinese
  - Don't explain basic concepts unless asked
```

### HEARTBEAT.md (Optional)

```markdown
# Heartbeat Tasks

## Periodic Tasks
- <task to run on each heartbeat>

## Alerts
- <condition that triggers immediate notification>

## Health Checks
- <service or system to verify>
```

**Purpose**: Instructions for periodic heartbeat turns — scheduled check-ins that happen even without a user message. Useful for health checks, queued item processing, scheduled reports.

**Loaded**: On heartbeat turns only (not every turn).

**Design principles**:
- Each task needs a clear termination condition — avoid open-ended instructions that cause loops
- Alert conditions should be specific and actionable
- Reference checklists for multi-step heartbeat tasks

**Anti-patterns**:
- Instructions that always send a message (creates noise)
- Open-ended monitoring with no exit condition (causes infinite loops)
- Duplicating daily task management from AGENTS.md

**Config optimization**: Enable `lightContext: true` in openclaw.json to minimize bootstrap injection on heartbeat turns:

```json5
{
  agents: {
    defaults: {
      heartbeat: {
        lightContext: true
      }
    }
  }
}
```

OpenClaw auto-skips execution when HEARTBEAT.md contains only empty lines and headers.

---

### BOOT.md (Optional)

```markdown
# Startup Actions

## Health Checks
- [ ] Verify <service> is reachable
- [ ] Confirm <tool> version

## Notifications
- [ ] Send "online" notification to <channel>
```

**Purpose**: Actions to run on gateway startup. Requires `hooks.internal.enabled = true` in config.

**Loaded**: On startup only.

**Design principles**:
- Keep startup actions fast and non-blocking
- Health check failures should notify, not abort startup
- Actions requiring user confirmation should be skipped or logged

**Anti-patterns**:
- Long initialization sequences that delay first response
- Actions that modify config (use `openclaw config set` manually)
- Duplicating what AGENTS.md boot sequence handles

---

### MEMORY.md (Main Agent Only)

```markdown
# Long-Term Memory

## Iron Laws
1. **<Rule name> (<category>)**: <One-sentence rule with context>
2. **<Rule name> (<category>)**: <One-sentence rule with context>

## Key Decisions
- <date>: <decision and rationale>

## Lessons Learned
- <date>: <lesson from incident or discovery>
```

**Purpose**: Long-term curated memory — significant events, decisions, lessons learned, and critical rules that must be in context every session.

**Loaded**: Main sessions only. **NEVER in group chats or sub-agent sessions.**

**Security rule**: The boot sequence in AGENTS.md must gate MEMORY.md loading: "Main session only." Private context must not leak to group chats or sub-agents.

**Design principles**:
- Curated essence, not raw logs — write significant events, decisions, opinions, lessons
- Short and atomic — one sentence to one short paragraph per entry
- Actively curate via heartbeat — review daily logs every few days, remove outdated entries
- Keep under 10,000 chars

**Anti-patterns**:
- Raw session logs or conversation transcripts (those belong in daily logs)
- Rules that duplicate content in skill SKILL.md files
- Task-specific notes (use daily logs or `memory_search`)
- Loading in groups or sub-agents (NEVER)
- Growing indefinitely without periodic distillation

---

### memory/YYYY-MM-DD.md (Daily Logs)

```markdown
# Session Log — YYYY-MM-DD

## Tasks
- <what was done>

## Decisions
- <key decision and rationale>

## Notes
- <anything to remember for next session>
```

**Purpose**: Session-by-session logs for the current day. Feeds the memory distillation process.

**Loaded**: Per AGENTS.md boot sequence (recommend loading today + yesterday for short-term continuity).

**Design principles**:
- Append-only during active sessions; summarize at end of day
- Facts worth keeping long-term should be promoted to MEMORY.md or stored via `memory_search`
- Archive or delete logs older than 30 days

---

### checklists/*.md (On Demand)

```markdown
# Checklist: <Operation Name>

## Pre-flight
- [ ] <Check or verify step>

## Execution
- [ ] <Action step>

## Verification
- [ ] Confirm outcome
- [ ] Log result in memory
```

**Purpose**: Step-by-step guides for high-risk operations. Referenced from AGENTS.md checklists table.

**Loaded**: On demand (agent reads the file before performing the operation).

**Design principles**:
- Completable in one reading — no back-and-forth lookups needed
- Keep under ~50 lines; move narrative to `docs/` if longer
- Register every checklist in the AGENTS.md checklists table

## Sub-Agent Bootstrap Context

Note: Sub-agents (spawned via `sessions_spawn`) only receive `AGENTS.md` and `TOOLS.md` in their bootstrap context. They do not receive `SOUL.md`, `IDENTITY.md`, `USER.md`, `HEARTBEAT.md`, or `BOOTSTRAP.md`. Design sub-agent tasks to be self-contained or include necessary context in the task description.

## Token Budget

| Constraint | Limit |
|-----------|-------|
| Per file | 20,000 chars (truncated if exceeded) |
| Total across all bootstrap files | ~150,000 chars |
| Recommended per file | 10,000–15,000 chars |
| MEMORY.md recommended max | 10,000 chars |

Files are read on every relevant turn, so token cost is multiplied by conversation length. Keep files lean.
