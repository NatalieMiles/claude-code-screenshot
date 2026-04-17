#!/bin/bash
# Removes the slash command and helper scripts installed by install.sh.
set -euo pipefail

CLAUDE_DIR="$HOME/.claude"
FILES=(
    "$CLAUDE_DIR/bin/list-capture-targets.swift"
    "$CLAUDE_DIR/bin/screenshot-picker.sh"
    "$CLAUDE_DIR/commands/screenshot.md"
)

for f in "${FILES[@]}"; do
    if [ -f "$f" ]; then
        rm "$f"
        echo "Removed: $f"
    fi
done

echo ""
echo "✓ Uninstalled."
echo ""
echo "Note: Screen Recording permission for your terminal is unchanged."
echo "Remove it manually in System Settings if you no longer want it."
