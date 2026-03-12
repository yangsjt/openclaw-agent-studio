#!/bin/bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/skill" && pwd)"
TARGET="$HOME/.claude/skills/openclaw-agent-studio"

mkdir -p "$(dirname "$TARGET")"
ln -sfn "$SKILL_DIR" "$TARGET"

echo "Installed openclaw-agent-studio skill -> $TARGET"
echo "Verify: ls -la $TARGET/SKILL.md"
