# Workspace Maintenance Guide

Day-to-day maintenance workflows for keeping workspace files lean, non-redundant, and within token budget.

## Token Budget Audit

### Check File Sizes

```bash
# All markdown files in workspace root
wc -c ~/.openclaw/workspace/*.md

# Check a specific workspace profile
wc -c ~/.openclaw/workspace-<agent-id>/*.md

# Total size of auto-loaded files
cat ~/.openclaw/workspace/AGENTS.md \
    ~/.openclaw/workspace/SOUL.md \
    ~/.openclaw/workspace/TOOLS.md \
    ~/.openclaw/workspace/USER.md \
    ~/.openclaw/workspace/IDENTITY.md \
    ~/.openclaw/workspace/MEMORY.md \
    2>/dev/null | wc -c
```

### Size Thresholds

| Size | Status | Action |
|------|--------|--------|
| Under 5,000 chars | Healthy | No action needed |
| 5,000–10,000 chars | Acceptable | Monitor for growth |
| 10,000–15,000 chars | Warning | Review for trimming |
| Over 15,000 chars | Needs optimization | Trim or offload to `docs/` |
| Over 20,000 chars | **Will be truncated** | Fix immediately |

**Target**: Under 80,000 chars total for the regularly-loaded set (AGENTS + SOUL + TOOLS + USER + IDENTITY + MEMORY).

## Redundancy Audit

Common sources of duplication across workspace files under the three-layer architecture:

| Source A | Source B | What to check | Resolution |
|----------|----------|---------------|------------|
| SOUL.md (personality traits) | system-prompt §1 (role) | Personality description duplicated as role description? | SOUL.md = inner essence; system-prompt = professional title |
| SOUL.md (values) | system-prompt §4 (constraints) | Values restated as operational rules? | Keep motivation in SOUL.md, derived action in system-prompt |
| SOUL.md (communication habits) | IDENTITY.md (style) | Communication style duplicated? | SOUL.md = inner habits; IDENTITY.md = external presentation |
| AGENTS.md (runtime context) | SOUL.md | Environment info still in SOUL.md? | Move to AGENTS.md §1 Runtime Context |
| AGENTS.md (directives) | system-prompt §2 (workflow) | Same workflow described in both? | Keep overview in system-prompt, specifics in AGENTS.md |
| TOOLS.md | MEMORY.md | Same tool note or SSH host? | Keep in TOOLS.md |
| MEMORY.md | Skill SKILL.md | Same rule in both? | Move stable rules to SKILL.md |
| AGENTS.md | docs/ file | Detailed explanation inline AND in docs? | Remove inline |
| USER.md | SOUL.md | User preferences in SOUL.md? | Keep in USER.md only |

### Three-Layer Separation Check

When auditing, verify the three layers are properly separated:

| Content type | Correct location | Wrong locations |
|-------------|-----------------|-----------------|
| Personality traits | SOUL.md §2 | system-prompt, AGENTS.md |
| Values & principles | SOUL.md §3 | system-prompt §4 (values ≠ constraints) |
| Communication habits | SOUL.md §4 | IDENTITY.md (habits ≠ style) |
| Name, emoji, catchphrase | IDENTITY.md | SOUL.md |
| Node Type, OS, hardware | AGENTS.md §1 | SOUL.md |
| Paths, tools, toolchain | AGENTS.md §1 | SOUL.md |
| Professional role/title | system-prompt §1 | SOUL.md §1 (essence ≠ job title) |
| Workflow procedures | system-prompt §2 | SOUL.md |
| Output format rules | system-prompt §3 | AGENTS.md |
| Security/permission rules | system-prompt §4 | SOUL.md §4 (constraints ≠ habits) |
| Task progress, decisions | MEMORY.md / daily logs | SOUL.md |

### When to Move Content to docs/

**Move to `docs/` when:**
- Content is only needed for specific operation types
- Content is reference material looked up on demand
- Content is long narrative (not rules or facts)
- Content is historical context for past tasks

**Keep in workspace files when:**
- Content affects every turn (persona, safety rules, checklist table)
- Content is short enough not to matter (< 200 chars)
- Content must be in context before the agent receives a message

## Staleness Audit

Check each workspace file for outdated content:

- **SOUL.md**: Personality traits that no longer fit the Agent's evolved role; values that conflict with actual behavior
- **IDENTITY.md**: Name or style that no longer matches the Agent's purpose or user preference
- **AGENTS.md**: Environment info that changed (hardware, OS version, tool versions); completed tasks in task queue; outdated directives
- **TOOLS.md**: SSH hosts that no longer exist, old device IDs, deprecated voice settings
- **USER.md**: Preferences that changed, projects that ended, contacts no longer relevant
- **MEMORY.md**: Rules about completed tasks, obsolete decisions, context that no longer applies
- **system-prompt**: Constraints that reference removed tools or workflows; role descriptions that no longer match

## Memory Distillation Workflow

### Via Heartbeat (Recommended)

Add to HEARTBEAT.md for automated periodic distillation:

```markdown
## Memory Maintenance (every few days)
1. Read recent memory/YYYY-MM-DD.md files
2. Identify significant events, lessons, insights worth keeping long-term
3. Update MEMORY.md with distilled learnings
4. Remove outdated entries from MEMORY.md
```

Track distillation state in `memory/heartbeat-state.json`:

```json
{
  "lastChecks": {
    "memoryDistillation": 1703275200
  }
}
```

### Manual Distillation (Monthly)

Run when MEMORY.md exceeds 10,000 chars or monthly:

**Step 1 — Gather daily logs:**

```bash
ls ~/.openclaw/workspace/memory/ | sort
```

Read logs from the past 30 days. Look for:
- Rules the agent had to re-learn (same mistake multiple times)
- Hard-won environment facts not in any skill doc
- Decisions that always get made the same way (candidates for iron laws)

**Step 2 — Promote to MEMORY.md:**

For each candidate:
1. Check if already in MEMORY.md (avoid duplicates)
2. Check if it belongs in a skill SKILL.md instead
3. Write in iron-law format:

```
N. **Rule name (category)**: One-sentence rule. Context if needed.
```

**Step 3 — Archive old logs:**

```bash
mkdir -p ~/.openclaw/workspace/memory/archive
find ~/.openclaw/workspace/memory -name "*.md" -mtime +30 \
  -exec mv {} ~/.openclaw/workspace/memory/archive/ \;
```

**Step 4 — Demote from MEMORY.md:**

Review each entry:
- Incident-free for 3+ months? → Move to a skill SKILL.md
- Covered by an existing skill doc now? → Remove the duplicate
- About a completed task? → Delete it

## Checklist Management

### Adding a New Checklist

1. Create `checklists/<operation-name>.md` with Pre-flight / Execution / Verification sections
2. Register in AGENTS.md checklists table:
   ```markdown
   | <Operation description> | `checklists/<filename>.md` |
   ```
3. Keep under ~50 lines — move narrative to `docs/` if longer

### Checklist Pattern

**Wrong**: Inline checklist steps in AGENTS.md (wastes tokens every turn)

**Right**: One-line table entry in AGENTS.md, full checklist in `checklists/`

## TOOLS.md Maintenance

TOOLS.md is loaded by sub-agents too — keep it tight.

**Include** (environment-specific only):
```markdown
## SSH
- main-server: ssh user@192.168.1.10

## TTS
- Provider: Edge | Voice: zh-CN-XiaoxiaoNeural

## Cameras
- Living room: node node-home, device camera-0
```

**Do NOT include**:
- General tool documentation (use skill docs)
- Things that are the same across all environments
- Installation instructions (use `docs/`)
- Configuration history ("used to be X, now Y")
- Anything over ~50 lines total

## Git Backup

Recommended: back up workspace files to a private Git repository.

```bash
cd ~/.openclaw/workspace
git init
git remote add origin <your-private-repo>
```

**Commit**: AGENTS.md, SOUL.md, TOOLS.md, IDENTITY.md, USER.md, HEARTBEAT.md, memory/*.md, checklists/, docs/

**Never commit**: secrets, .env, .key/.pem, credentials, anything containing API keys or tokens.

## Quick Wins

When time is short, audit in this priority order:

1. **Three-layer separation** — Is personality in SOUL.md? Environment in AGENTS.md? Constraints in system-prompt?
2. **MEMORY.md** — most frequent source of bloat; apply "curated essence" standard
3. **AGENTS.md inline content** — anything more than a one-liner → `docs/` reference
4. **TOOLS.md cruft** — dead SSH hosts, old device IDs, deprecated settings
5. **USER.md staleness** — changed preferences, ended projects, old contacts
6. **Checklist table vs inline** — ensure AGENTS.md has the table, not the steps
7. **HEARTBEAT.md `lightContext`** — enable in config to reduce heartbeat token cost

## Common Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| File exceeds token limit | Over 20,000 chars; OpenClaw truncates | Move detailed content to `docs/` |
| MEMORY.md leaking to groups | Agent shares private context in group chats | Gate in AGENTS.md: "Main session only: Read MEMORY.md" |
| Boot sequence not loading files | Agent doesn't know about SOUL.md/USER.md content | Check AGENTS.md boot sequence explicitly names each file |
| MEMORY.md growing too large | Exceeds 10,000 chars | Run memory distillation; move stable rules to skill SKILL.md |
| Workspace changes not taking effect | Agent uses old content after edits | Restart gateway or start new session |
| Personality in wrong file | Traits in system-prompt or AGENTS.md | Move to SOUL.md; keep only derived rules elsewhere |
| Environment info in SOUL.md | Legacy format with Node Type, paths in SOUL.md | Migrate to AGENTS.md §1 Runtime Context (see Pattern 10) |
