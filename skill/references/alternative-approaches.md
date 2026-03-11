# Alternative Agent Creation Approaches

Beyond the standard SOUL.md-driven Agent creation, OpenClaw supports two additional approaches for specialized use cases.

## ACP Agents (External Runtime)

ACP (Agent Communication Protocol) agents spawn external AI runtimes (Codex, Claude Code, Gemini CLI, OpenCode) as managed sessions within OpenClaw.

### When to Use

- Need capabilities of a specific external AI runtime (e.g., Codex code execution, Claude Code file operations)
- Want to leverage IDE-specific agent features
- Need persistent external sessions with thread binding

### Quick Start

```
/acp spawn codex --mode persistent --thread auto
```

### Supported Runtimes

| Harness | Agent ID |
|---------|----------|
| Pi (OpenClaw internal) | `pi` |
| Claude Code | `claude` |
| Codex | `codex` |
| OpenCode | `opencode` |
| Gemini CLI | `gemini` |

### Key Configuration

```json5
{
  acp: {
    enabled: true,
    dispatch: { enabled: true },
    backend: "acpx",
    defaultAgent: "codex",
    allowedAgents: ["pi", "claude", "codex", "opencode", "gemini"],
    maxConcurrentSessions: 8,
  },
}
```

### Setup Requirements

1. Install acpx plugin: `openclaw plugins install @openclaw/acpx`
2. Enable in config: `acp.enabled: true`, `acp.dispatch.enabled: true`
3. Configure allowed agents: `acp.allowedAgents`
4. Verify: `/acp doctor`

### Key Commands

| Command | Description |
|---------|-------------|
| `/acp spawn <agent> --mode persistent --thread auto` | Create session |
| `/acp status` | Check session state |
| `/acp steer <message>` | Nudge without replacing context |
| `/acp close` | Close session |
| `/acp sessions` | List active sessions |

## Sub-agents (Internal Nested Sessions)

Sub-agents are isolated sessions spawned from the main Agent to parallelize work without blocking the main run. They use the internal Pi runtime.

### When to Use

- Parallelize independent research tasks
- Delegate long-running operations without blocking
- Need temporary workers that don't require full Agent setup

### Quick Start

Via tool call:
```json
{
  "tool": "sessions_spawn",
  "params": {
    "task": "Research best practices for rate limiting in Node.js",
    "label": "rate-limit-research",
    "runTimeoutSeconds": 300
  }
}
```

Via slash command:
```
/subagents spawn main "Research best practices for rate limiting in Node.js"
```

### Key Configuration

```json5
{
  agents: {
    defaults: {
      subagents: {
        maxSpawnDepth: 2,           // Allow nested sub-agents
        maxChildrenPerAgent: 5,     // Max active children per session
        maxConcurrent: 8,           // Global concurrency cap
        runTimeoutSeconds: 900,     // Default timeout
      },
    },
  },
}
```

### Key Commands

| Command | Description |
|---------|-------------|
| `/subagents spawn <agent> <task>` | Create sub-agent |
| `/subagents list` | List active sub-agents |
| `/subagents kill <id\|all>` | Stop sub-agent(s) |
| `/subagents log <id>` | View transcript |
| `/subagents send <id> <msg>` | Send message to sub-agent |

### Limitations

- Sub-agents only receive `AGENTS.md` + `TOOLS.md` in bootstrap (no SOUL.md, IDENTITY.md, USER.md)
- Maximum nesting depth: 5 (depth 2 recommended)
- Sessions are ephemeral — archived after `archiveAfterMinutes` (default: 60)

## Comparison: Three Approaches

| Dimension | SOUL.md-Driven Agent | ACP Agent | Sub-agent |
|-----------|---------------------|-----------|-----------|
| **Runtime** | Internal Pi | External process (Codex, Claude, etc.) | Internal Pi |
| **Persistence** | Full workspace + SOUL.md | Session-level | Session-level |
| **Independence** | Fully independent | Semi-independent | Depends on parent Agent |
| **Bootstrap Files** | All 6 files | External runtime config | AGENTS.md + TOOLS.md only |
| **Workspace** | Dedicated directory | Shared or external | Inherits parent workspace |
| **Configuration** | openclaw.json `agents.list` | `acp` config section | `subagents` config section |
| **Channel Binding** | Via `bindings` | Via thread binding | Via thread binding |
| **Use Case** | Long-running specialized Agent | External AI runtime capabilities | Temporary parallel tasks |
| **Setup Effort** | High (workspace + files + config) | Medium (plugin + config) | Low (tool call or slash command) |

## Decision Guide

Choose the right approach based on your needs:

```
Need a persistent, dedicated Agent with full identity?
  → SOUL.md-Driven Agent (this skill's main workflow)

Need specific external AI runtime capabilities (Codex, Claude Code, Gemini)?
  → ACP Agent

Need to parallelize work temporarily without dedicated setup?
  → Sub-agent

Need an Agent that survives Gateway restarts with full memory?
  → SOUL.md-Driven Agent

Need a quick one-shot task delegation?
  → Sub-agent (mode: "run")

Need persistent thread-bound external session?
  → ACP Agent (mode: "persistent", thread: "auto")
```
