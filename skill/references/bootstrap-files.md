# Bootstrap Files System

OpenClaw injects bootstrap files into the Agent workspace (`agents.defaults.workspace`) during setup. These files define the Agent's personality, instructions, tools, and user context.

## File Overview

| File | Purpose | Required |
|------|---------|----------|
| `SOUL.md` | Persona, boundaries, tone + environment awareness | **Required** |
| `AGENTS.md` | Operating instructions + persistent "memory" | Recommended |
| `TOOLS.md` | User-maintained tool usage notes | Recommended |
| `BOOTSTRAP.md` | One-time first-run ritual (auto-deleted after completion) | Optional |
| `IDENTITY.md` | Agent name, style, emoji | Optional |
| `USER.md` | User profile + preferred address | Optional |

These files are created by `openclaw setup` and can be manually edited at any time.

To skip bootstrap file injection: `{ agent: { skipBootstrap: true } }`.

## File Relationships

```
SOUL.md (identity + environment)
  ├── AGENTS.md reads SOUL.md for context
  ├── TOOLS.md referenced by AGENTS.md instructions
  ├── IDENTITY.md extends SOUL.md personality
  └── USER.md informs SOUL.md communication style

BOOTSTRAP.md (one-time setup → deleted after first run)
```

- **SOUL.md** is the foundation — all other files reference or extend it
- **AGENTS.md** contains operational instructions that assume SOUL.md identity
- **TOOLS.md** documents tools referenced in AGENTS.md instructions
- **IDENTITY.md** and **USER.md** are personality/context layers on top of SOUL.md
- **BOOTSTRAP.md** runs once to initialize the workspace, then self-deletes

## File Templates

### SOUL.md (Required)

See [soul-md-spec.md](soul-md-spec.md) for the full specification and examples.

### AGENTS.md (Recommended)

```markdown
# Agent Operating Instructions

## Primary Directives
- <core behavior directive 1>
- <core behavior directive 2>

## Task Queue
1. <current priority task>
2. <next task>

## Response Guidelines
- <how to format responses>
- <when to ask for clarification>
- <escalation rules>

## Memory Log
- <date>: <key decision or progress note>
- <date>: <important context for future sessions>
```

**Purpose**: AGENTS.md serves as the Agent's "operating manual" — it tells the Agent what to do and how to do it. The Memory Log section acts as persistent memory across sessions.

**Example** (Coding Agent):

```markdown
# Agent Operating Instructions

## Primary Directives
- Follow TDD: write tests first, then implement
- Use conventional commits for all git operations
- Run linter and type checker before committing

## Task Queue
1. Complete user authentication module (OAuth2 + JWT)
2. Add rate limiting to API endpoints
3. Write integration tests for payment flow

## Response Guidelines
- When given a bug report, reproduce first, then fix
- For architectural decisions, present 2-3 options with trade-offs
- Commit only when explicitly asked

## Memory Log
- 2026-03-01: Decided on Drizzle ORM over Prisma for type safety
- 2026-03-05: Auth flow uses PKCE code flow, approved by user
- 2026-03-10: Database migration for users table completed
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

### BOOTSTRAP.md (Optional)

```markdown
# First-Run Bootstrap

Complete these setup steps on first activation, then delete this file.

## Steps
1. [ ] Verify all tools listed in TOOLS.md are installed
2. [ ] Run `git status` to confirm workspace is clean
3. [ ] Read SOUL.md and confirm environment matches
4. [ ] <project-specific setup step>
5. [ ] <project-specific setup step>

## On Completion
Delete this file after all steps are verified.
```

**Purpose**: BOOTSTRAP.md defines a one-time setup ritual. The Agent executes these steps on its first run, then deletes the file. This is useful for initial workspace verification, dependency installation, or configuration checks.

### IDENTITY.md (Optional)

```markdown
# Agent Identity

- **Name**: <display name>
- **Emoji**: <representative emoji>
- **Style**: <communication style description>
- **Catchphrase**: <optional signature phrase>
```

**Example**:

```markdown
# Agent Identity

- **Name**: Atlas
- **Emoji**: :globe_with_meridians:
- **Style**: Professional but approachable. Uses technical terms precisely but explains them when context suggests the audience may not be familiar.
- **Catchphrase**: "Let me map that out for you."
```

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

## Sub-Agent Bootstrap Context

Note: Sub-agents (spawned via `sessions_spawn`) only receive `AGENTS.md` and `TOOLS.md` in their bootstrap context. They do not receive `SOUL.md`, `IDENTITY.md`, `USER.md`, `HEARTBEAT.md`, or `BOOTSTRAP.md`. Design sub-agent tasks to be self-contained or include necessary context in the task description.
