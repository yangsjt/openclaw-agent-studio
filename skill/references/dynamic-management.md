# Dynamic Agent Management

## Architecture Overview: Gateway Compatibility Model

### Components

- **Gateway (Command Center)**: Handles logic routing, metadata management, and message dispatch
- **Local Node**: The Gateway machine itself; suitable for single-machine deployment or simple tasks
- **Remote Node**: External devices (Mac mini, cloud instance, Chromebook) connected to Gateway via WebSocket
- **Node Selector**: Tags or ID-based targeting when creating an Agent; if unset and no Remote Node connected, defaults to local execution

### Physical Storage Logic

Agent workspace files and SOUL.md are always stored on the **current execution node's disk**, whether local or remote.

## Core Principle: Configuration as File

The Agent's identity and configuration are decomposed into physical files in the workspace directory using a three-layer architecture:

- **SOUL.md (Inner Core)**: Personality, values, and communication habits — constant across all environments
- **IDENTITY.md (External Expression)**: Name, emoji, style — adjustable per scenario
- **AGENTS.md (Operations)**: Runtime context, workflows, constraints — changes per deployment (system-prompt.md serves as design source)

Key properties:
- **Physical persistence**: Configuration moves with the workspace. As long as disk is intact, settings are never lost
- **Environment self-adaptation**: On startup, the Agent reads AGENTS.md §1 Runtime Context to determine its environment, and SOUL.md to internalize its personality

## System Prompt for Dynamic Agents

Dynamic agents (created via channel bindings with `dynamicAgents.enabled: true`) do
not have a dedicated `agentDir` and therefore no standalone `system-prompt.md`.

### Recommended: Operations in AGENTS.md

Transfer all operations content into AGENTS.md — the same approach used for
static agents. This keeps the pattern consistent:

- **SOUL.md**: Personality core only (WHO) — copied from parent agent
- **AGENTS.md**: Runtime context + operations (WHAT/HOW) — adapted for channel context
- **IDENTITY.md**: External expression — same as or adjusted from parent

### Anti-pattern: Merging into SOUL.md

Do NOT merge system-prompt operations content into SOUL.md. This violates the
three-layer architecture:
- SOUL.md should remain personality-only ("the soul is constant")
- Mixing operations into SOUL.md makes maintenance difficult
- Updates to operations require touching the personality file

If a dynamic workspace has operations merged into SOUL.md, consider migrating:
split the SOUL.md back into pure personality (SOUL.md) + operations (AGENTS.md).

## Three Maintenance Layers

### A. Gateway Layer: Routing & Bootstrap

- **Scope**: Gateway management console
- **Content**: Bootstrap prompt (system prompt), Node selection strategy
- **Local execution note**: Ensure the Gateway process has sufficient disk read/write permissions

### B. Node Layer: Workspace Files (SOUL.md + AGENTS.md + IDENTITY.md)

- **Scope**: Workspace root directory files
- **Content**: SOUL.md (personality core), AGENTS.md (runtime context, operating instructions, node-specific paths), IDENTITY.md (external presentation)
- **Updates**: Agent writes progress to MEMORY.md or daily logs at task milestones

### C. Recording Layer: Execution History (Git)

- **Scope**: Workspace Git repository
- **Purpose**: Track changes to workspace files, SOUL.md updates, and code changes
- **Recommendation**: Initialize Git in every workspace for cross-node sync capability

## Memory Mechanism

### Context Memory (Session-scoped)

- Maintained by the Gateway
- Isolated per session
- Lost when session ends or is archived
- Includes conversation history, tool call results, and intermediate reasoning

### Persistent Memory (File-based)

- Maintained on the Node's disk via MEMORY.md and daily logs (`memory/YYYY-MM-DD.md`)
- Survives across sessions
- Agent writes key progress to MEMORY.md (curated long-term) or daily logs (session-level)
- Enables "checkpoint resume" — Agent can pick up where it left off

### Best Practice

Combine both memory types:
1. Use Context Memory for within-session state
2. Write session progress to daily logs (`memory/YYYY-MM-DD.md`)
3. Distill significant learnings into MEMORY.md periodically
4. At session end, ensure important context is persisted to the appropriate memory file

## Cross-Node Migration

To migrate an Agent from Node A to Node B:

### Step 1: Copy Workspace

Copy the entire workspace directory (including SOUL.md and all bootstrap files) from Node A to Node B:

```bash
# From Node A
rsync -avz ~/.openclaw/workspace-<agent-id>/ nodeB:~/.openclaw/workspace-<agent-id>/

# Or via Git (if workspace is a git repo)
# On Node A: git push
# On Node B: git clone / git pull
```

### Step 2: Create Migration BOOTSTRAP.md

Create a migration-specific BOOTSTRAP.md on Node B to verify the new environment before resuming operations:

```markdown
# Migration Verification Bootstrap

## Context
This Agent is being migrated from Node A to Node B.
This bootstrap verifies that the new environment is correctly
configured before the Agent resumes normal operations.

## Steps

### 1. Detect — Verify Workspace Integrity
- Confirm all bootstrap files transferred successfully (SOUL.md, AGENTS.md, IDENTITY.md, TOOLS.md, MEMORY.md)
- Check git history is intact (if workspace uses git)
- Verify no file corruption from transfer

### 2. Validate — New Node Environment
- Verify required tools are installed on Node B (check AGENTS.md §1 Toolchain list)
- Confirm working directory paths are valid on Node B
- Test tool accessibility (e.g., `which kubectl`, `docker --version`)

### 3. Update — Runtime Context
- Update AGENTS.md §1 Runtime Context for Node B (Node Type, OS, Working Directory, Hardware)
- Verify SOUL.md is unchanged (personality is environment-independent)

### 4. Test — Functional Verification
- Run `openclaw doctor` on Node B
- Send a test prompt to confirm Agent responds with correct personality and role

### 5. Complete — Delete and Record
- Delete this BOOTSTRAP.md file
- Git commit: "chore: complete migration bootstrap from <node-a> to <node-b>"
```

> See [optimization-guide.md Pattern 11](optimization-guide.md#pattern-11-retrofit-bootstrapmd-for-established-agents) for the general retrofit pattern.

### Step 3: Update AGENTS.md Runtime Context

Edit AGENTS.md on Node B to reflect the new environment:

```markdown
## 1. Runtime Context
- **Node Type**: Remote Node          # Updated
- **OS**: Ubuntu 24.04 LTS            # Updated for new node
- **Working Directory**: /home/ops/workspace  # Updated
- **Toolchain**: kubectl, helm, docker, terraform  # Verified
- **Hardware Note**: 8-core Xeon, 32GB RAM  # Updated
```

> **Note**: SOUL.md (personality core) does not need updating during migration — the Agent's personality is environment-independent.

### Step 4: Update Node Selector

In `openclaw.json`, update the Agent's Node selector to point to Node B:

```json5
{
  agents: {
    list: [{
      id: "<agent-id>",
      workspace: "~/.openclaw/workspace-<agent-id>",
      // Update node selector
      tools: {
        exec: { node: "<node-b-id-or-name>" },
      },
    }],
  },
}
```

### Step 5: Verify

```bash
openclaw nodes status                  # Confirm Node B is online
openclaw agents list --bindings        # Verify Agent config
openclaw agent "Confirm your environment from SOUL.md"  # Test
```

## Node Operations Reference

### Node Status

```bash
openclaw nodes status                  # List all connected nodes
openclaw nodes describe --node <id>    # Detailed node info
openclaw devices list                  # List paired devices
```

### Node Connection

```bash
# Start a remote node host
openclaw node run --host <gateway-host> --port 18789 --display-name "Build Node"

# Install as a service
openclaw node install --host <gateway-host> --port 18789 --display-name "Build Node"

# Via SSH tunnel (when Gateway uses loopback bind)
ssh -N -L 18790:127.0.0.1:18789 user@gateway-host
openclaw node run --host 127.0.0.1 --port 18790 --display-name "Build Node"
```

### Exec Routing to Node

```bash
openclaw config set tools.exec.node "<node-id-or-name>"
openclaw config set tools.exec.security allowlist
```

## FAQ

**Q: Why can't the Agent find my remote Node?**
A: Check that the Node selector tags match, and confirm the Node shows as `Online` in `openclaw nodes status`. If connecting via SSH tunnel, verify the tunnel is active and the `OPENCLAW_GATEWAY_TOKEN` is correct.

**Q: Do I still need SOUL.md if I only run locally on the Gateway?**
A: Yes. SOUL.md defines the Agent's personality core — its character traits, values, and communication style. Without it, the Agent has no consistent personality. Runtime environment info goes in AGENTS.md §1 Runtime Context.

**Q: How do I implement cross-node migration?**
A: Copy the entire workspace folder from Machine A to Machine B, create a Migration Verification BOOTSTRAP.md to validate the new environment (tools, paths, workspace integrity), update AGENTS.md §1 Runtime Context for the new node's environment, and update the Node selector in `openclaw.json` to point to Machine B. SOUL.md does not need updating — personality is environment-independent. See the Cross-Node Migration section above for the full 5-step process.

**Q: What happens to session history during migration?**
A: Session history (Context Memory) stays on the Gateway. Only workspace files (SOUL.md, AGENTS.md, IDENTITY.md, MEMORY.md, etc.) are migrated. The Agent picks up context from MEMORY.md and daily logs on the new node.

**Q: Can multiple Agents share the same Node?**
A: Yes, but each Agent should have its own workspace directory. The Node Selector routes exec commands to the node; workspace isolation is handled at the directory level.
