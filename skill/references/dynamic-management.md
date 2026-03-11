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

The Agent's "soul" is decomposed into physical files in the workspace directory:

- **Physical persistence**: Configuration moves with the workspace. As long as disk is intact, settings are never lost
- **Environment self-adaptation**: On startup, the Agent reads SOUL.md to determine if it's on a local Gateway or remote Node, then loads the appropriate environment variables

## Three Maintenance Layers

### A. Gateway Layer: Routing & Bootstrap

- **Scope**: Gateway management console
- **Content**: Bootstrap prompt (system prompt), Node selection strategy
- **Local execution note**: Ensure the Gateway process has sufficient disk read/write permissions

### B. Node Layer: Soul Files (SOUL.md)

- **Scope**: Workspace root directory files
- **Content**: Role definition, node-specific paths (e.g., `/home` on Linux vs `/Users` on macOS)
- **Updates**: Agent writes progress to SOUL.md Memory section at task milestones

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

- Maintained on the Node's disk via SOUL.md
- Survives across sessions
- Agent writes key progress to SOUL.md's `[Memory]` entries
- Enables "checkpoint resume" — Agent can pick up where it left off

### Best Practice

Combine both memory types:
1. Use Context Memory for within-session state
2. Write critical milestones to SOUL.md `[Memory]` entries
3. At session end, ensure important context is persisted to SOUL.md

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

### Step 2: Update SOUL.md

Edit SOUL.md on Node B to reflect the new environment:

```markdown
## 1. Environment Info
- **Node Type**: Remote Node          # Updated
- **OS**: Ubuntu 24.04 LTS            # Updated for new node
- **Hardware Note**: 8-core Xeon, 32GB RAM  # Updated
```

### Step 3: Update Node Selector

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

### Step 4: Verify

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
A: Yes. SOUL.md helps the Agent distinguish between system-global configuration and project-specific configuration. It also works around the limitation that dynamic Agents cannot directly access the system prompt at runtime.

**Q: How do I implement cross-node migration?**
A: Copy the entire workspace folder (containing SOUL.md) from Machine A to Machine B, update SOUL.md's environment section for the new node, and update the Node selector in `openclaw.json` to point to Machine B.

**Q: What happens to session history during migration?**
A: Session history (Context Memory) stays on the Gateway. Only workspace files (Persistent Memory / SOUL.md) are migrated. The Agent picks up context from SOUL.md's Memory entries on the new node.

**Q: Can multiple Agents share the same Node?**
A: Yes, but each Agent should have its own workspace directory. The Node Selector routes exec commands to the node; workspace isolation is handled at the directory level.
