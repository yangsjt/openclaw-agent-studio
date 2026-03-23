#!/bin/bash
# workspace-audit.sh — Quick workspace health check for OpenClaw Agents
# Usage: bash workspace-audit.sh [workspace-path]
#
# Checks required/recommended files, token budget thresholds,
# SOUL.md section structure, and common misconfigurations.

set -euo pipefail

WORKSPACE="${1:-$(pwd)}"
WARN=0
CRIT=0

echo "============================================"
echo "  OpenClaw Workspace Audit"
echo "  Path: $WORKSPACE"
echo "============================================"
echo ""

# --- File Existence ---
echo "## File Existence"

check_file() {
  local file="$1" level="$2" label="$3"
  if [ -f "$WORKSPACE/$file" ]; then
    echo "  [OK]   $file ($label)"
  else
    echo "  [$level] $file — missing ($label)"
    [ "$level" = "CRIT" ] && CRIT=$((CRIT + 1))
    [ "$level" = "WARN" ] && WARN=$((WARN + 1))
  fi
}

check_file "SOUL.md"      "CRIT" "Required"
check_file "AGENTS.md"    "WARN" "Recommended"
check_file "TOOLS.md"     "WARN" "Recommended"
check_file "IDENTITY.md"  "WARN" "Recommended"
check_file "USER.md"      "INFO" "Optional"
check_file "MEMORY.md"    "INFO" "Optional"
check_file "HEARTBEAT.md" "INFO" "Optional"

# Warn if system-prompt.md exists (not auto-loaded!)
if [ -f "$WORKSPACE/system-prompt.md" ]; then
  echo "  [WARN] system-prompt.md found — this file is NOT auto-loaded by OpenClaw!"
  echo "         Transfer its content to AGENTS.md. See gotchas.md #1."
  WARN=$((WARN + 1))
fi

echo ""

# --- Token Budget ---
echo "## Token Budget"

TOTAL=0
for f in AGENTS.md SOUL.md TOOLS.md USER.md IDENTITY.md MEMORY.md; do
  if [ -f "$WORKSPACE/$f" ]; then
    SIZE=$(wc -c < "$WORKSPACE/$f" | tr -d ' ')
    TOTAL=$((TOTAL + SIZE))
    if [ "$SIZE" -gt 20000 ]; then
      echo "  [CRIT] $f — ${SIZE} chars (will be truncated, limit 20k)"
      CRIT=$((CRIT + 1))
    elif [ "$SIZE" -gt 15000 ]; then
      echo "  [WARN] $f — ${SIZE} chars (needs optimization, target <15k)"
      WARN=$((WARN + 1))
    elif [ "$SIZE" -gt 10000 ]; then
      echo "  [WARN] $f — ${SIZE} chars (review for trimming)"
      WARN=$((WARN + 1))
    else
      echo "  [OK]   $f — ${SIZE} chars"
    fi
  fi
done

echo "  ---"
if [ "$TOTAL" -gt 80000 ]; then
  echo "  [CRIT] Total: ${TOTAL} chars (exceeds 80k budget)"
  CRIT=$((CRIT + 1))
else
  echo "  [OK]   Total: ${TOTAL} chars (within 80k budget)"
fi

echo ""

# --- SOUL.md Structure ---
if [ -f "$WORKSPACE/SOUL.md" ]; then
  echo "## SOUL.md Section Check (5 sections expected)"
  for section in "Role" "Core Personality" "Values" "Communication" "Memory"; do
    if grep -qi "$section" "$WORKSPACE/SOUL.md" 2>/dev/null; then
      echo "  [OK]   Section found: $section"
    else
      echo "  [WARN] Section missing: $section"
      WARN=$((WARN + 1))
    fi
  done
  echo ""
fi

# --- Summary ---
echo "============================================"
if [ "$CRIT" -gt 0 ]; then
  echo "  Result: FAIL — $CRIT critical, $WARN warnings"
elif [ "$WARN" -gt 0 ]; then
  echo "  Result: PASS with warnings — $WARN warnings"
else
  echo "  Result: PASS — workspace is healthy"
fi
echo "============================================"

exit "$CRIT"
