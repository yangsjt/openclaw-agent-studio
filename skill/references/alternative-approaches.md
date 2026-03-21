# Alternative Agent Approaches

Beyond the standard SOUL.md-driven Agent creation, OpenClaw supports additional approaches for specialized use cases.

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

## A2A Communication (Agent-to-Agent via sessions_send)

A2A enables agents to communicate directly with each other using the `sessions_send` tool, forming collaborative agent teams where each worker has **full Agent-level capabilities** — unlike sub-agents which only receive AGENTS.md + TOOLS.md.

### When to Use

- Need a worker agent with **full bootstrap context** (SOUL.md, all files, full workspace)
- Need multi-turn collaboration between agents (ping-pong dialogue)
- Need to delegate work to an agent that maintains its own persistent identity and memory
- Building agent teams where each member is a fully independent Agent

### How It Works

Agent A uses `sessions_send` to send a message to Agent B's session:

```json
{
  "tool": "sessions_send",
  "params": {
    "sessionKey": "agent:<target-agent-id>:main",
    "message": "Please analyze the authentication module and report findings"
  }
}
```

Agent B processes the message with its **full bootstrap context** (SOUL.md, AGENTS.md, TOOLS.md, IDENTITY.md, MEMORY.md) and responds. The response flows back to Agent A.

### Key Properties

- **Full bootstrap context**: Unlike sub-agents (AGENTS.md + TOOLS.md only), A2A targets are complete agents with all bootstrap files
- **Ping-pong dialogue**: Supports multi-turn exchanges (configurable via `session.agentToAgent.maxPingPongTurns`; use `REPLY_SKIP` to end the exchange)
- **Independent identity**: Each agent maintains its own SOUL.md personality and workspace
- **Persistent**: Target agent persists across interactions (unlike ephemeral sub-agents)

### Configuration

Enable A2A by including `sessions_send` in the agent's available tools (included by default):

```json5
{
  tools: {
    // sessions_send is available by default
    // To explicitly deny A2A for a specific agent:
    // deny: ["sessions_send"],
  },
}
```

**AGENTS.md tool visibility**: Default include `sessions_send` in AGENTS.md tools section. Only omit when the agent explicitly should not have A2A capability. Omitting the tool description is a soft control — the LLM will not call a tool it does not know about.

### Sub-agent vs. A2A: Bootstrap Context Comparison

| Aspect | Sub-agent (sessions_spawn) | A2A (sessions_send) |
|--------|--------------------------|---------------------|
| Bootstrap files loaded | AGENTS.md + TOOLS.md only | **All files** (SOUL.md, AGENTS.md, TOOLS.md, IDENTITY.md, USER.md, MEMORY.md) |
| Personality | None (no SOUL.md) | Full personality from target's SOUL.md |
| Memory access | No MEMORY.md, no memory_search | Full memory pipeline |
| Workspace | Inherits parent workspace | Own dedicated workspace |
| Persistence | Ephemeral (archived after timeout) | Persistent across sessions |
| Communication model | Task delegation (one-shot or session) | Dialogue (ping-pong) |

## Comparison: Four Approaches

| Dimension | SOUL.md-Driven Agent | ACP Agent | Sub-agent | A2A (sessions_send) |
|-----------|---------------------|-----------|-----------|---------------------|
| **Runtime** | Internal Pi | External process (Codex, Claude, etc.) | Internal Pi | Internal Pi (target agent) |
| **Persistence** | Full workspace + SOUL.md | Session-level | Session-level | Full workspace + SOUL.md |
| **Independence** | Fully independent | Semi-independent | Depends on parent Agent | Fully independent |
| **Bootstrap Files** | All files | External runtime config | AGENTS.md + TOOLS.md only | **All files** (target agent) |
| **Workspace** | Dedicated directory | Shared or external | Inherits parent workspace | Dedicated directory (target) |
| **Configuration** | openclaw.json `agents.list` | `acp` config section | `subagents` config section | `sessions_send` tool + target agent config |
| **Channel Binding** | Via `bindings` | Via thread binding | Via thread binding | N/A (direct agent session) |
| **Use Case** | Long-running specialized Agent | External AI runtime capabilities | Temporary parallel tasks | Agent team collaboration |
| **Setup Effort** | High (workspace + files + config) | Medium (plugin + config) | Low (tool call or slash command) | Medium (both agents must exist) |

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

Need a worker with full personality, memory, and bootstrap context?
  → A2A (sessions_send to a fully-configured target agent)

Need multi-turn collaboration between two independent agents?
  → A2A (sessions_send with ping-pong)

Need a lightweight parallel worker (no personality needed)?
  → Sub-agent (only gets AGENTS.md + TOOLS.md — fastest to set up)
```
