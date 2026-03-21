# Agent Creation Checklist

## Information Gathering

Before creating an Agent, collect the following:

| Item | Description | Example |
|------|-------------|---------|
| Agent ID | Unique identifier (lowercase, no spaces) | `coding`, `social`, `ops-monitor` |
| Purpose | What the Agent does | "Fullstack development for project X" |
| Execution Node | Where it runs | Local Gateway / Remote Node (tags) |
| Workspace Path | Directory for Agent files | `~/.openclaw/workspace-coding` |
| Model | Primary model + fallbacks | `anthropic/claude-sonnet-4-5` |
| Channel Binding | Which channel(s) route to this Agent | Telegram `coding` account |
| Permissions | Tools the Agent needs | `read_file`, `write_file`, `execute_command`, `list_files` |
| **Inner Essence** | Agent's core identity (for SOUL.md §1 Role) | "A meticulous craftsman" |
| **Personality Traits** | 3-5 character traits (for SOUL.md §2) | Patient, rigorous, curious |
| **Core Values** | Decision-making principles (for SOUL.md §3) | Safety first, simplicity over cleverness |
| **Communication Habits** | How the Agent naturally communicates (for SOUL.md §4) | Uses analogies, asks before assuming |
| **Professional Title** | Job title for system-prompt §1 | Senior Fullstack Developer |
| **Name & Style** | External expression (for IDENTITY.md) | Name: Atlas, Style: Professional but approachable |

### Personality Collection Tips

When gathering personality information, use these prompts:

1. **Role**: "If this Agent were a person, how would they describe themselves in one sentence — not their job, but their nature?"
2. **Personality**: "What 3-5 adjectives best describe this Agent's temperament?"
3. **Values**: "When faced with a trade-off (speed vs. quality, convenience vs. security), what does this Agent prioritize?"
4. **Communication**: "How does this Agent naturally explain things — with examples? analogies? step-by-step?"

### Motivation-Action Derivation

After collecting personality, derive system-prompt constraints using the motivation-action chain:

| Personality trait (SOUL.md) | → Operational rule (system-prompt) |
|---|---|
| "Rigorous — treats edge cases as first-class" | → "Write tests for error paths before happy paths" |
| "Safety first — never trade security for convenience" | → "Schema-validate all input; use parameterized queries" |
| "Patient — never rushes decisions" | → "Read existing code context before making changes" |

## Creation Checklist

### Workspace Setup

- [ ] **Determine execution node** and verify availability
  - Local: Ensure Gateway process has disk read/write permissions
  - Remote: Confirm Node is online via `openclaw nodes status`
- [ ] **Create workspace directory**
  ```bash
  mkdir -p ~/.openclaw/workspace-<agent-id>
  ```
- [ ] **Write SOUL.md** (inner core — all 5 sections filled)
  - Role (inner essence, not job title)
  - Core Personality (3-5 character traits)
  - Values & Principles (decision-making compass)
  - Communication Habits (natural interaction patterns)
  - Memory Management (write discipline, trigger words, recall habits)
- [ ] **Write IDENTITY.md** (external expression)
  - Name, Emoji, Style, Catchphrase
- [ ] **Write AGENTS.md** (runtime context + operating instructions + task queue)
  - Runtime Context (Node Type, OS, Working Directory, Toolchain)
  - Operation Workflow (task queue, directives)
  - Response Guidelines
- [ ] **Write BOOTSTRAP.md** (first-run ritual — auto-deleted after execution)
  - Verify tools from AGENTS.md Runtime Context are installed
  - Confirm workspace is clean (`git status`)
  - Read SOUL.md and confirm personality internalized
  - Add project-specific setup steps
- [ ] **Write system prompt** using the operation manual template
  - Section 0: Bootstrap preamble (standard)
  - Section 1: Role & Mission (professional identity)
  - Section 2: Workflow & Tools (procedures)
  - Section 3: Output Format (language, formatting)
  - Section 4: Operational Constraints (hard rules)

### Configuration

- [ ] **Register Agent** in `openclaw.json` (`agents.list` entry)
- [ ] **Configure channel binding** (`bindings` entry)
- [ ] **Configure tool permissions** (`read_file`, `write_file`, `execute_command`, `list_files`)
- [ ] **Select model** (primary + fallbacks)

### Initialization

- [ ] **Initialize Git** in workspace (recording layer)
  ```bash
  cd ~/.openclaw/workspace-<agent-id> && git init
  ```
- [ ] **Run `openclaw doctor`** to validate system health
- [ ] **Test Agent** via `openclaw agent` CLI or channel message

## openclaw.json Configuration Template

Copy and customize this template:

```json5
{
  // === Agent Registration ===
  agents: {
    // Default settings (applied to all agents unless overridden)
    defaults: {
      workspace: "~/.openclaw/workspace",
      model: {
        primary: "anthropic/claude-sonnet-4-5",
        fallbacks: ["openai/gpt-5.2"],
      },
    },

    // Agent list
    list: [
      {
        id: "<agent-id>",
        workspace: "~/.openclaw/workspace-<agent-id>",
        // Per-agent model override (optional)
        // model: { primary: "anthropic/claude-opus-4-6" },
        // Per-agent tools override (optional)
        // tools: { profile: "coding" },
        // Group chat mention patterns (optional)
        // groupChat: { mentionPatterns: ["@<agent-id>"] },
      },
    ],
  },

  // === Channel Bindings ===
  bindings: [
    {
      agentId: "<agent-id>",
      match: {
        channel: "<channel-name>",    // "whatsapp" | "telegram" | "discord" | "slack"
        accountId: "<account-id>",    // Channel account ID
        // peer: { kind: "direct", id: "<peer-id>" },  // Specific peer (optional)
      },
    },
  ],

  // === Tools Configuration ===
  tools: {
    profile: "full",                  // "minimal" | "coding" | "messaging" | "full"
    // allow: [],                     // Explicit allowlist (if set, everything else blocked)
    // deny: [],                      // Block specific tools
    exec: {
      security: "allow",             // "allow" | "ask" | "deny"
    },
  },
}
```

### Binding Match Fields

| Field | Description | Example |
|-------|-------------|---------|
| `channel` | Channel name | `"whatsapp"`, `"telegram"`, `"discord"` |
| `accountId` | Channel account ID | `"personal"`, `"work"` |
| `peer.kind` | DM or group | `"direct"`, `"group"` |
| `peer.id` | Specific sender/group ID | `"+15551234567"`, `"group-jid@g.us"` |

### Binding Priority

Bindings are matched **first match wins** (order matters). Place specific bindings before general ones:

```json5
{
  bindings: [
    // Most specific: specific peer on specific account
    { agentId: "vip", match: { channel: "whatsapp", peer: { kind: "direct", id: "+1555VIP" } } },
    // Medium specific: all traffic on a specific account
    { agentId: "work", match: { channel: "telegram", accountId: "work" } },
    // Least specific: all traffic on a channel
    { agentId: "daily", match: { channel: "whatsapp" } },
  ],
}
```

Unmatched messages fall through to `agents.defaults`.

## Post-Creation Verification

### System Health

```bash
openclaw doctor                        # Full system diagnostic
openclaw config validate               # Validate config syntax
```

### Agent Registration

```bash
openclaw agents list                   # Verify Agent appears in list
openclaw agents list --bindings        # Verify channel bindings
```

### Functional Test

```bash
# Test via CLI
openclaw agent "Hello, please introduce yourself and confirm your SOUL.md is loaded."

# Test via channel (send a message on the bound channel)
# Verify the Agent responds with its configured identity
```

### Checklist Verification

- [ ] `openclaw doctor` passes with no errors
- [ ] Agent appears in `openclaw agents list`
- [ ] Bindings are correct in `openclaw agents list --bindings`
- [ ] Agent responds to test prompt with correct personality (from SOUL.md)
- [ ] Agent uses correct professional identity (from system-prompt §1)
- [ ] Agent respects operational constraints (from system-prompt §4)
- [ ] Agent displays correct name and style (from IDENTITY.md)

## See Also

- [optimization-guide.md](optimization-guide.md) — Audit and optimize existing Agents against the three-layer architecture spec
