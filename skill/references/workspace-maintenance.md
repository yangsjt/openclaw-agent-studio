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

Common sources of duplication across workspace files:

| Source A | Source B | What to check | Resolution |
|----------|----------|---------------|------------|
| SOUL.md (values) | AGENTS.md (rules) | Safety rules in both? | Keep in AGENTS.md, remove from SOUL.md |
| TOOLS.md | MEMORY.md | Same tool note or SSH host? | Keep in TOOLS.md |
| MEMORY.md | Skill SKILL.md | Same rule in both? | Move stable rules to SKILL.md |
| AGENTS.md | docs/ file | Detailed explanation inline AND in docs? | Remove inline |
| USER.md | SOUL.md | User preferences duplicated? | Keep in USER.md only |

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

- **TOOLS.md**: SSH hosts that no longer exist, old device IDs, deprecated voice settings
- **USER.md**: Preferences that changed, projects that ended, contacts no longer relevant
- **MEMORY.md**: Rules about completed tasks, obsolete decisions, context that no longer applies
- **AGENTS.md**: Checklist entries for operations no longer performed, outdated task queue items
- **SOUL.md**: Environment info that changed (hardware, OS version, tool versions)

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

1. **MEMORY.md** — most frequent source of bloat; apply "curated essence" standard
2. **AGENTS.md inline content** — anything more than a one-liner → `docs/` reference
3. **TOOLS.md cruft** — dead SSH hosts, old device IDs, deprecated settings
4. **USER.md staleness** — changed preferences, ended projects, old contacts
5. **Checklist table vs inline** — ensure AGENTS.md has the table, not the steps
6. **HEARTBEAT.md `lightContext`** — enable in config to reduce heartbeat token cost

## Common Issues

| Issue | Symptom | Fix |
|-------|---------|-----|
| File exceeds token limit | Over 20,000 chars; OpenClaw truncates | Move detailed content to `docs/` |
| MEMORY.md leaking to groups | Agent shares private context in group chats | Gate in AGENTS.md: "Main session only: Read MEMORY.md" |
| Boot sequence not loading files | Agent doesn't know about SOUL.md/USER.md content | Check AGENTS.md boot sequence explicitly names each file |
| MEMORY.md growing too large | Exceeds 10,000 chars | Run memory distillation; move stable rules to skill SKILL.md |
| Workspace changes not taking effect | Agent uses old content after edits | Restart gateway or start new session |
