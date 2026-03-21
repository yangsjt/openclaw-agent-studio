# Agent Optimization Guide

Audit and optimize existing OpenClaw Agents against the three-layer architecture spec (SOUL.md inner core + IDENTITY.md expression + system-prompt operations).

## Optimization Workflow Overview

1. **Audit** — Collect workspace files and configuration
2. **Analyze** — Run gap analysis against spec checklists
3. **Report** — Generate structured findings with severity
4. **Fix** — Apply changes using optimization patterns
5. **Verify** — Confirm fixes via doctor + functional test

## Step 1: Audit — Collect Agent State

Gather the current state of the target Agent:

```bash
# 1. List workspace files
ls -la ~/.openclaw/workspace-<agent-id>/

# 2. Read SOUL.md (if exists)
cat ~/.openclaw/workspace-<agent-id>/SOUL.md

# 3. Read other bootstrap files
cat ~/.openclaw/workspace-<agent-id>/AGENTS.md
cat ~/.openclaw/workspace-<agent-id>/TOOLS.md
cat ~/.openclaw/workspace-<agent-id>/IDENTITY.md

# 4. Read Agent config from openclaw.json
cat ~/.openclaw/openclaw.json | grep -A 20 '"<agent-id>"'

# 5. Check git status (recording layer)
cd ~/.openclaw/workspace-<agent-id> && git log --oneline -5
```

## Step 2: Analyze — Gap Analysis Checklists

### SOUL.md Audit

| Check | Severity | Pass Criteria |
|-------|----------|---------------|
| SOUL.md exists | Critical | File present in workspace root |
| Section 1: Role | High | Inner essence defined (not just a job title) |
| Section 2: Core Personality | High | 3-5 character traits listed with explanations |
| Section 3: Values & Principles | High | Decision-making principles defined |
| Section 4: Communication Habits | Medium | Natural communication patterns described |
| Section 5: Memory Management | Medium | Memory write/trigger/recall habits defined |
| No environment/path/tool info | Medium | Environment info is in AGENTS.md, not SOUL.md |
| No operational constraints | Medium | Constraints are in system-prompt §4, not SOUL.md |
| No memory entries | Medium | Memory is in MEMORY.md, not SOUL.md |
| File uses uppercase `SOUL.md` | Low | Not `soul.md` or `Soul.md` |

Reference: [soul-md-spec.md](soul-md-spec.md) for the gold-standard template and field definitions.

### System Prompt Audit

| Check | Severity | Pass Criteria |
|-------|----------|---------------|
| Section 0: Bootstrap preamble present | Critical | 5-step mechanism (Detect/Bootstrap/Awaken/Adapt/WriteBack) |
| Section 1: Role & Mission | High | Professional identity and task scope defined |
| Section 2: Workflow & Tools | High | Work procedures and tool usage rules |
| Section 3: Output Format | Medium | Language, formatting, and style rules |
| Section 4: Operational Constraints | High | Hard security rules and prohibitions |
| Restriction clause | High | "No operations before SOUL.md confirmation" present |
| Motivation-action alignment | Medium | Constraints traceable to SOUL.md personality traits |
| Operations coverage in AGENTS.md | High | All 5 system-prompt sections have corresponding content in AGENTS.md |
| No redundancy between files | Medium | system-prompt content not duplicated between AGENTS.md, SOUL.md, TOOLS.md |
| Step 3 references new SOUL.md structure | Low | "性格、价值观与沟通习惯" not old "身份、任务目标" |
| Step 5 references MEMORY.md | Low | Write-back targets MEMORY.md, not SOUL.md |

Reference: [system-prompt-template.md](system-prompt-template.md) for the standard template.

### Bootstrap Files Audit

| Check | Severity | Pass Criteria |
|-------|----------|---------------|
| SOUL.md present | Critical | Required file exists |
| AGENTS.md present | High | Recommended file exists with Runtime Context + directives |
| AGENTS.md §1 Runtime Context | High | Node Type, OS, Working Directory, Toolchain present |
| TOOLS.md present | Medium | Recommended file exists listing workspace tools |
| IDENTITY.md present | Medium | Recommended — name, emoji, style, catchphrase |
| BOOTSTRAP.md handled | Medium | Present (not yet run), absent with git history showing prior creation, or retrofit applied per Pattern 11 |
| USER.md present | Low | Optional — check if user preferences are documented |
| MEMORY.md (not in SOUL.md) | Medium | Memory lives in MEMORY.md, not embedded in SOUL.md |

Reference: [bootstrap-files.md](bootstrap-files.md) for templates and file relationships.

### Configuration Audit

| Check | Severity | Pass Criteria |
|-------|----------|---------------|
| Agent in `agents.list` | Critical | Entry with correct `id` exists |
| `workspace` path valid | Critical | Path exists on disk and matches actual workspace |
| Channel binding exists | High | At least one `bindings` entry routes to this Agent |
| Tool permissions set | Medium | Appropriate `tools` profile or allow/deny list |
| Model configured | Low | Primary model set (or inherits from defaults) |

## Step 3: Report — Severity Levels

| Level | Meaning | Action |
|-------|---------|--------|
| **Critical** | Agent cannot function correctly | Must fix before use |
| **High** | Core feature degraded or missing | Fix immediately |
| **Medium** | Best practice not followed | Fix when possible |
| **Low** | Enhancement opportunity | Nice to have |

### Report Template

```markdown
# Agent Optimization Report: <agent-id>

## Summary
- **Agent**: <agent-id>
- **Workspace**: <path>
- **Audit Date**: <date>
- **Architecture**: <legacy 4-section / new 3-layer / mixed>
- **Findings**: X Critical, X High, X Medium, X Low

## Findings

### Critical
- [ ] <finding description> → <recommended fix>

### High
- [ ] <finding description> → <recommended fix>

### Medium
- [ ] <finding description> → <recommended fix>

### Low
- [ ] <finding description> → <recommended fix>

## Recommended Fix Order
1. <most critical fix first>
2. <next priority>
3. ...
```

## Step 4: Fix — Common Optimization Patterns

### Pattern 1: Empty or Minimal SOUL.md

**Symptom**: SOUL.md is missing, empty, or has no personality content.

**Fix**: Generate complete SOUL.md using the [standard template](soul-md-spec.md#standard-template) with all 4 sections (Role / Core Personality / Values & Principles / Communication Habits). Gather personality traits from the user or infer from the Agent's purpose.

### Pattern 2: Hardcoded System Prompt

**Symptom**: `instruction` field contains role-specific instructions directly instead of the bootstrap + operation manual pattern.

**Fix**: Restructure into 5 sections: bootstrap preamble (standard) + Role & Mission + Workflow & Tools + Output Format + Operational Constraints. See [system-prompt-template.md](system-prompt-template.md#complete-system-prompt-example-coding-agent).

### Pattern 3: Missing AGENTS.md

**Symptom**: Operating instructions and environment context are either absent or embedded in SOUL.md.

**Fix**: Create AGENTS.md with Runtime Context (§1), Primary Directives, Task Queue, Response Guidelines, and Memory Log. Migrate environment info from SOUL.md if present.

### Pattern 4: Stale Memory / Context

**Symptom**: Memory entries reference outdated tasks, completed work, or obsolete context.

**Fix**: Archive old memory entries to MEMORY.md or `memory/archive/`. Update AGENTS.md Task Queue. Refresh Memory Log to reflect current state.

### Pattern 5: Missing Constraints

**Symptom**: System prompt has no §4 Operational Constraints, leaving the Agent with no behavioral boundaries.

**Fix**: Add role-appropriate constraints to system-prompt §4. Derive constraints from SOUL.md personality traits using the motivation-action chain. Common constraints by role:
- **Coding**: "Must run tests before committing", "No direct .env modification"
- **Ops**: "No destructive commands without confirmation", "Terraform plan before apply"
- **Social**: "No messages to contacts outside allowlist", "Draft work replies for review"

### Pattern 6: Workspace-Config Path Mismatch

**Symptom**: `workspace` in `openclaw.json` does not match the actual directory where bootstrap files live.

**Fix**: Verify actual workspace location. Update either the config path or move files to match. Ensure AGENTS.md §1 Working Directory is also consistent.

### Pattern 7: No Git Recording Layer

**Symptom**: Workspace directory is not a git repository. No change history.

**Fix**: Initialize git and create initial commit:
```bash
cd ~/.openclaw/workspace-<agent-id>
git init
git add SOUL.md AGENTS.md TOOLS.md IDENTITY.md
git commit -m "chore: initialize agent workspace recording layer"
```

### Pattern 8: Personality Content in System Prompt

**Symptom**: System prompt contains personality descriptions, character traits, or value statements that belong in SOUL.md. For example: "你是一个耐心、严谨的助手" directly in the instruction field.

**Fix**: Extract personality content to SOUL.md:
1. Identify personality traits embedded in the system prompt
2. Create or update SOUL.md with proper 4-section structure
3. Keep only the professional role definition in system-prompt §1
4. Derive operational rules from the extracted personality using the motivation-action chain

**Example**:
- **Before** (system prompt): "你是一个严谨的开发者，所有代码必须经过测试。"
- **After** (SOUL.md): "Rigorous — treats every detail as if it matters" → (system-prompt §4): "All code changes must pass the full test suite before commit."

### Pattern 9: Operational Rules in SOUL.md

**Symptom**: SOUL.md contains operational constraints, workflow procedures, or tool usage rules that belong in system-prompt or AGENTS.md. For example: `[Constraint]: Must run tests before committing` in SOUL.md.

**Fix**: Migrate operational content to the correct location:
1. Move `[Constraint]` entries about operations → AGENTS.md Safety section
2. Move workflow descriptions → AGENTS.md + TOOLS.md
3. Move environment/path/tool info → AGENTS.md §1 (Runtime Context)
4. Move `[Memory]` entries → MEMORY.md or daily logs
5. Keep only personality-level boundaries in SOUL.md §3 (Values & Principles)

**Example**:
- **Before** (SOUL.md): `[Constraint]: Do not modify .env files directly`
- **After** (system-prompt §4): `禁止直接修改 .env 或 .env.local 文件`

### Pattern 10: Legacy SOUL.md Format Migration

**Symptom**: SOUL.md uses the old 4-section format (Environment Info / Identity & Goals / Path & Tools / Constraints & Memory) instead of the new personality-focused format.

**Fix**: Migrate content to the three-layer architecture:

| Old SOUL.md section | Migration target |
|---------------------|-----------------|
| §1 Environment Info (Node Type, OS, Hardware) | → AGENTS.md §1 Runtime Context |
| §2 Identity & Goals → Role (job title) | → system-prompt §1 Role & Mission |
| §2 Identity & Goals → Current Task | → AGENTS.md §3 Task Queue |
| §3 Path & Tools | → AGENTS.md §1 Runtime Context |
| §4 [Constraint] (operational) | → system-prompt §4 Operational Constraints |
| §4 [Constraint] (personality boundary) | → SOUL.md §3 Values & Principles |
| §4 [Memory] | → MEMORY.md |
| Environment Self-Healing Log | → AGENTS.md Environment Self-Healing Log |

Then rewrite SOUL.md with the new 4-section structure focused on personality:
1. Role → inner essence (not job title)
2. Core Personality → 3-5 character traits
3. Values & Principles → decision-making compass
4. Communication Habits → interaction patterns

> **Backward compatibility**: The bootstrap mechanism does not parse section headings, so old-format SOUL.md files continue to work. Migration improves clarity and enables the motivation-action chain.

### Pattern 11: Retrofit BOOTSTRAP.md for Established Agents

**Symptom**: Agent was created before BOOTSTRAP.md became Recommended. No BOOTSTRAP.md exists and no git history of prior creation. This also applies to Agents undergoing cross-node migration or major environment changes.

**When to apply**:
- Agent predates BOOTSTRAP.md Recommended status and has never had one
- Agent is being migrated to a different Node (see [dynamic-management.md](dynamic-management.md#cross-node-migration))
- Agent's execution environment has changed significantly (OS upgrade, toolchain swap)

**Fix**: Create an **upgrade verification** variant of BOOTSTRAP.md (distinct from the first-run version used for new Agents):

```markdown
# Upgrade Verification Bootstrap

## Context
This Agent was created before BOOTSTRAP.md became Recommended.
This bootstrap performs a one-time upgrade verification to confirm
workspace integrity and align with current best practices.

## Steps

### 1. Detect — Verify Workspace Structure
- Confirm SOUL.md exists and uses the 4-section personality format
- Confirm AGENTS.md exists with Runtime Context (§1)
- List all bootstrap files present; flag any missing Recommended files

### 2. Validate — Environment Consistency
- Read AGENTS.md §1 Runtime Context
- Verify Node Type, OS, Working Directory, and Toolchain match actual environment
- Flag any stale or incorrect entries

### 3. Check — SOUL.md Format Compliance
- Verify 4-section structure: Role / Core Personality / Values & Principles / Communication Habits
- Flag any misplaced content (environment info, operational constraints, memory entries)
- If legacy format detected, recommend Pattern 10 migration

### 4. Align — Motivation-Action Chain
- Verify system-prompt §4 constraints are traceable to SOUL.md personality traits
- Flag orphaned constraints (no personality basis) or unused traits (no operational rule)

### 5. Complete — Delete and Record
- Delete this BOOTSTRAP.md file
- Git commit: "chore: complete upgrade verification bootstrap for <agent-id>"
```

> **Audit trail**: The git commit message serves as proof that the retrofit was applied, satisfying the Bootstrap Files Audit check (this pattern's pass criteria).

> **Cross-node migration**: For migration scenarios, use the Migration Verification Bootstrap variant described in [dynamic-management.md](dynamic-management.md#cross-node-migration) instead.

### Pattern 12: System Prompt Content Not Transferred to AGENTS.md

**Symptom**: `agent/system-prompt.md` exists as a design document but its content
has not been (fully) transferred into AGENTS.md. The Agent is missing operational
guidance at runtime.

**Diagnosis**:
1. Read `agent/system-prompt.md` — identify its 5 sections
2. Read workspace `AGENTS.md` — check which sections are covered
3. Generate a coverage matrix:

| system-prompt Section | In AGENTS.md? | In TOOLS.md? | Missing? |
|----------------------|---------------|--------------|----------|
| §0 Bootstrap Preamble | Check §1 Boot Sequence | — | ? |
| §1 Role & Mission | Check §2 Primary Directives | — | ? |
| §2 Workflow & Tools | Check §3 Task Queue | Check tool list | ? |
| §3 Output Format | Check §4 Response Guidelines | — | ? |
| §4 Constraints | Check §7 Safety | — | ? |

**Fix**:
1. Transfer missing sections from system-prompt.md into AGENTS.md
2. Move tool-specific details to TOOLS.md
3. Remove any duplicated content between files
4. Keep system-prompt.md in `agent/` for version control reference

**Also check for redundancy**:
- SOUL.md containing operational constraints → move to AGENTS.md
- AGENTS.md duplicating SOUL.md personality content → remove from AGENTS.md
- system-prompt content in both SOUL.md and AGENTS.md → keep only in AGENTS.md

## Step 5: Verify — Post-Optimization

After applying fixes, verify the Agent works correctly:

```bash
# System health
openclaw doctor

# Config validation
openclaw config validate

# Agent registration
openclaw agents list --bindings

# Functional test
openclaw agent "Please confirm your personality, professional role, and list your constraints."
```

### Verification Checklist

- [ ] `openclaw doctor` passes with no errors
- [ ] Agent responds with personality traits from SOUL.md
- [ ] Agent identifies its professional role from system-prompt §1
- [ ] Agent respects constraints from system-prompt §4
- [ ] Agent displays correct identity from IDENTITY.md (name, style)
- [ ] AGENTS.md contains Runtime Context with accurate environment info
- [ ] Git recording layer tracks the optimization changes
