#!/bin/bash
# Installer for claude-code-screenshot.
# Copies the slash command + helper scripts into ~/.claude, then prints next steps.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BIN_DIR="$CLAUDE_DIR/bin"
CMD_DIR="$CLAUDE_DIR/commands"

if [ "$(uname)" != "Darwin" ]; then
    echo "ERROR: macOS only. This tool uses macOS-specific APIs (CoreGraphics, screencapture, osascript)."
    exit 1
fi

mkdir -p "$BIN_DIR" "$CMD_DIR"

echo "Installing helper scripts → $BIN_DIR"
cp "$REPO_DIR/bin/list-capture-targets.swift" "$BIN_DIR/"
cp "$REPO_DIR/bin/screenshot-picker.sh" "$BIN_DIR/"
chmod +x "$BIN_DIR/list-capture-targets.swift" "$BIN_DIR/screenshot-picker.sh"

echo "Installing slash command → $CMD_DIR"
cp "$REPO_DIR/commands/screenshot.md" "$CMD_DIR/"

echo ""
echo "✓ Installed."
echo ""
echo "Next steps:"
echo "  1. Grant your terminal Screen Recording permission (one-time):"
echo "       System Settings → Privacy & Security → Screen & System Audio Recording"
echo "       Click [+], add your terminal app (Terminal.app, iTerm, Ghostty, etc.)"
echo "  2. Fully quit your terminal (Cmd+Q) and reopen it — TCC permissions only attach at process start."
echo "  3. In Claude Code, run: /screenshot"
echo ""
echo "Why the permission is needed: macOS Sequoia (15+) routes screencapture's"
echo "non-interactive flags (-l for window-by-id, -D for display) through"
echo "ScreenCaptureKit, which requires explicit Screen Recording permission for"
echo "the calling process."
