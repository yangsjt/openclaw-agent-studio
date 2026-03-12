# Agent Optimization Guide

Audit and optimize existing OpenClaw Agents against the SOUL.md-driven architecture spec.

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
| Section 1: Environment Info | High | Node Type, OS, Hardware Note all filled |
| Section 2: Identity & Goals | High | Role and Current Task defined |
| Section 3: Path & Tools | High | Root Path matches actual workspace; tools listed |
| Section 4: Constraints & Memory | Medium | At least 1 constraint; memory entries present if not new |
| Environment Self-Healing Log | Low | Section exists (can be empty for new agents) |
| File uses uppercase `SOUL.md` | Low | Not `soul.md` or `Soul.md` |

Reference: [soul-md-spec.md](soul-md-spec.md) for the gold-standard template and field definitions.

### System Prompt Audit

| Check | Severity | Pass Criteria |
|-------|----------|---------------|
| Uses bootstrap loader pattern | Critical | `instruction` contains the 5-step mechanism |
| Step 1: Detect | High | Environment detection (Gateway vs Node) present |
| Step 2: Bootstrap | High | SOUL.md loading via `list_files`/`read_file` present |
| Step 3: Awaken | High | Identity inheritance from SOUL.md described |
| Step 4: Adapt | Medium | OS path adaptation mentioned |
| Step 5: Write Back | High | State persistence to SOUL.md mandated |
| Restriction clause | High | "no operations before SOUL.md confirmation" present |

Reference: [system-prompt-template.md](system-prompt-template.md) for the standard bootstrap loader template.

### Bootstrap Files Audit

| Check | Severity | Pass Criteria |
|-------|----------|---------------|
| SOUL.md present | Critical | Required file exists |
| AGENTS.md present | High | Recommended file exists with directives + task queue |
| TOOLS.md present | Medium | Recommended file exists listing workspace tools |
| BOOTSTRAP.md handled | Low | Either present (not yet run) or absent (already run) |
| IDENTITY.md present | Low | Optional — check if Agent has a defined persona |
| USER.md present | Low | Optional — check if user preferences are documented |

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

**Symptom**: SOUL.md is missing, empty, or has fewer than 4 sections.

**Fix**: Generate complete SOUL.md using the [standard template](soul-md-spec.md#standard-template). Fill all 4 sections by inspecting the workspace environment (`uname`, `sw_vers`, tool versions).

### Pattern 2: Hardcoded System Prompt

**Symptom**: `instruction` field contains role-specific instructions directly instead of the bootstrap loader pattern.

**Fix**: Replace with the [standard bootstrap loader template](system-prompt-template.md#standard-template). Move role-specific instructions into SOUL.md (Identity & Goals) and AGENTS.md (directives).

### Pattern 3: Missing AGENTS.md

**Symptom**: Operating instructions and task context are either absent or embedded in SOUL.md Section 4.

**Fix**: Create AGENTS.md with Primary Directives, Task Queue, Response Guidelines, and Memory Log. Migrate operational content out of SOUL.md Constraints section.

### Pattern 4: Stale Memory / Context

**Symptom**: SOUL.md Memory entries reference outdated tasks, completed work, or obsolete context.

**Fix**: Archive old memory entries to a `memory-archive.md` file. Update Current Task in Section 2. Refresh Memory entries to reflect current state.

### Pattern 5: Missing Constraints

**Symptom**: SOUL.md Section 4 has no `[Constraint]` entries, leaving the Agent with no behavioral boundaries.

**Fix**: Add role-appropriate constraints. Common constraints by role:
- **Coding**: "Must run tests before committing", "No direct .env modification"
- **Ops**: "No destructive commands without confirmation", "Terraform plan before apply"
- **Social**: "No messages to contacts outside allowlist", "Draft work replies for review"

### Pattern 6: Workspace-Config Path Mismatch

**Symptom**: `workspace` in `openclaw.json` does not match the actual directory where bootstrap files live.

**Fix**: Verify actual workspace location. Update either the config path or move files to match. Ensure SOUL.md Root Path (Section 3) is also consistent.

### Pattern 7: No Git Recording Layer

**Symptom**: Workspace directory is not a git repository. No change history.

**Fix**: Initialize git and create initial commit:
```bash
cd ~/.openclaw/workspace-<agent-id>
git init
git add SOUL.md AGENTS.md TOOLS.md
git commit -m "chore: initialize agent workspace recording layer"
```

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
openclaw agent "Please confirm your identity, current task, and list your constraints."
```

### Verification Checklist

- [ ] `openclaw doctor` passes with no errors
- [ ] Agent responds with identity matching SOUL.md Section 2
- [ ] Agent references its constraints from SOUL.md Section 4
- [ ] Agent can read and write to its workspace
- [ ] Git recording layer tracks the optimization changes
