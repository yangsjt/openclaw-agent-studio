# Common Gotchas

Frequent mistakes and misconceptions when creating, optimizing, or maintaining OpenClaw Agents. Organized by severity.

## P0 — Critical (will break the Agent)

### 1. system-prompt.md is NEVER Auto-Loaded

**Problem**: Users create `system-prompt.md` in the workspace expecting OpenClaw to inject it at runtime. The Agent never sees the content.

**Why**: OpenClaw auto-loads only 8 bootstrap files: SOUL.md, AGENTS.md, TOOLS.md, IDENTITY.md, USER.md, HEARTBEAT.md, BOOTSTRAP.md, MEMORY.md. `system-prompt.md` is not in this list — it is a **design artifact** used during Agent creation to plan the 5-section operation manual.

**Fix**:
1. Draft operations in `system-prompt.md` using the [5-section template](system-prompt-template.md)
2. Transfer each section into AGENTS.md using the mapping table:
   - §0 Bootstrap Preamble → AGENTS.md §1 Boot Sequence
   - §1 Role & Mission → AGENTS.md §2 Primary Directives
   - §2 Workflow & Tools → AGENTS.md §3 Task Queue + TOOLS.md
   - §3 Output Format → AGENTS.md §4 Response Guidelines
   - §4 Constraints → AGENTS.md §7 Safety
3. Keep `system-prompt.md` in `agent/` for version control reference only

**Source**: Git commit `afe5ae1` — "clarified system-prompt.md as design artifact, not runtime file"

---

### 2. SOUL.md is Personality Only — No Environment, Constraints, or Memory

**Problem**: Users embed environment info (Node Type, OS, paths), operational constraints (`[Constraint]: Must run tests`), and memory entries (`[Memory]: ...`) into SOUL.md.

**Why**: SOUL.md defines the Agent's **inner core** — who they are, not what they do. Mixing operational content into SOUL.md violates the three-layer architecture and makes the personality layer unstable (it should never change across deployments).

**Fix** — move content to the correct layer:

| Content | Wrong location | Correct location |
|---------|---------------|-----------------|
| Node Type, OS, hardware | SOUL.md | AGENTS.md §1 Runtime Context |
| Paths, tools, toolchain | SOUL.md | AGENTS.md §1 Runtime Context |
| Operational constraints | SOUL.md | AGENTS.md §7 Safety (derived from system-prompt §4) |
| Workflow procedures | SOUL.md | AGENTS.md §3 Task Queue + TOOLS.md |
| `[Memory]` entries | SOUL.md | MEMORY.md or `memory/YYYY-MM-DD.md` |
| Task progress, decisions | SOUL.md | MEMORY.md or daily logs |

**Source**: [optimization-guide.md](optimization-guide.md) Patterns 8, 9, 10

---

### 3. Motivation-Action Chain is Required, Not Optional

**Problem**: Users write system-prompt §4 constraints like "Must run tests before committing" without connecting them to a SOUL.md personality trait. The Agent follows rules but does not understand WHY.

**Why**: The motivation-action chain is the core innovation of the three-layer architecture. SOUL.md traits (WHY) drive system-prompt rules (HOW). Without this link, constraints are arbitrary — the Agent cannot reason about edge cases or prioritize conflicting rules.

**Fix**:
1. For each constraint in system-prompt §4, identify the SOUL.md trait that motivates it
2. If no trait exists, either add one to SOUL.md or question whether the constraint is needed
3. Document the chain in the system-prompt comment or AGENTS.md

**Examples**:
- "Rigorous" (SOUL §2) → "All code changes must pass the full test suite before commit" (§4)
- "Security-conscious" (SOUL §3) → "Never store secrets in source code" (§4)
- "Empathetic" (SOUL §2) → "Draft work replies for user review before sending" (§4)

**Source**: [creation-checklist.md](creation-checklist.md) motivation-action derivation table

---

## P1 — High (degraded functionality)

### 4. Sub-Agents Only Get AGENTS.md + TOOLS.md

**Problem**: Users design sub-agent tasks assuming they have access to SOUL.md personality, MEMORY.md context, or IDENTITY.md styling. Sub-agents behave generically instead of embodying the Agent's character.

**Why**: Sub-agents (via `sessions_spawn`) receive a **minimal bootstrap**: only AGENTS.md and TOOLS.md. They do NOT get SOUL.md, IDENTITY.md, USER.md, HEARTBEAT.md, BOOTSTRAP.md, or MEMORY.md. This is by design — sub-agents are ephemeral workers, not full Agent instances.

**Fix**:
- For tasks requiring personality context → use **A2A** (`sessions_send`) instead, which gives the target Agent its full bootstrap
- For ephemeral worker tasks → sub-agents are correct; design the task to not depend on personality or memory
- For reference, see the comparison table in [alternative-approaches.md](alternative-approaches.md)

| Agent Type | SOUL.md | AGENTS.md | TOOLS.md | MEMORY.md | IDENTITY.md |
|-----------|---------|-----------|----------|-----------|-------------|
| Main Agent | Yes | Yes | Yes | Yes | Yes |
| Sub-agent | No | Yes | Yes | No | No |
| A2A target | Yes | Yes | Yes | Yes | Yes |
| Dynamic | No | Yes | Yes | No | No |

**Source**: [alternative-approaches.md](alternative-approaches.md), [bootstrap-files.md](bootstrap-files.md) sub-agent section

---

### 5. MEMORY.md Not Loaded in Group Chats or Sub-Agent Sessions

**Problem**: Agents write critical long-term decisions to MEMORY.md expecting it to be available everywhere. In group chats and sub-agent delegations, the Agent cannot recall these decisions.

**Why**: MEMORY.md is loaded in **main sessions only**. Group chats and sub-agent sessions never see it. This prevents private context from leaking into shared conversations.

**Fix**:
- Gate MEMORY.md loading in AGENTS.md boot sequence: `"Main session only: Read MEMORY.md"`
- Write session-level progress to `memory/YYYY-MM-DD.md` (daily logs)
- Use `memory_search` for recall (semantic search, not file-based loading)
- Only write to MEMORY.md what must be in every main session (critical decisions, iron laws)

**Source**: [bootstrap-files.md](bootstrap-files.md) — "MEMORY.md Loaded: Main sessions only. NEVER in group chats or sub-agent sessions."

---

## P2 — Medium (subtle issues)

### 6. A2A Tool Visibility: Default-Include Pattern

**Problem**: Users are unsure whether `sessions_send` (A2A communication) should be listed in AGENTS.md tools. Some agents accidentally call it; others cannot collaborate because it was omitted.

**Why**: `sessions_send` is **included by default** in an Agent's available tools. Omitting the tool description from AGENTS.md is a "soft denial" — the LLM will not call a tool it does not know about. For a hard block, use `tools.deny` in openclaw.json.

**Fix**:
- **Default** (most agents): Include `sessions_send` in AGENTS.md tools section
- **Soft deny** (agent should not initiate A2A): Omit from AGENTS.md tools list — the LLM won't know about it
- **Hard deny** (must never use A2A): Add `tools.deny: ["sessions_send"]` in openclaw.json

Only omit `sessions_send` when the Agent explicitly should not have A2A capability.

**Source**: User feedback — "Default include sessions_send in tools; only omit when explicitly required"

---

### 7. BOOTSTRAP.md Retrofit vs First-Run — Two Distinct Patterns

**Problem**: Users apply the first-run BOOTSTRAP.md template to existing Agents that predate BOOTSTRAP.md. The first-run template skips critical validation steps needed for legacy Agents.

**Why**: BOOTSTRAP.md has two variants:
- **First-run** (new Agents): Tool verification, workspace setup, SOUL.md internalization. Auto-deleted after first session.
- **Upgrade verification** (legacy Agents): Workspace integrity check, format compliance audit, motivation-action chain validation. Proves the retrofit was applied via git commit.

**Fix**:
- For **new Agents** → use the standard first-run template from [bootstrap-files.md](bootstrap-files.md)
- For **legacy Agents** → use the upgrade verification variant from [optimization-guide.md](optimization-guide.md#pattern-11-retrofit-bootstrapmd-for-established-agents)
- For **cross-node migration** → use the migration verification variant from [dynamic-management.md](dynamic-management.md#cross-node-migration)

**Audit pass criteria** (three valid states):
1. BOOTSTRAP.md present (first-run not yet executed)
2. BOOTSTRAP.md absent WITH git history showing prior creation (has been run)
3. Retrofit applied — git commit message: `chore: complete upgrade verification bootstrap`

**Source**: Git commit `9dfab7c` — "add BOOTSTRAP.md retrofit pattern and promote to Recommended"
