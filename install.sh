#!/bin/bash
# Installer for claude-code-screenshot.
# Copies the slash command + helper scripts into ~/.claude, then prints next steps.
# Prompts before overwriting any existing files. Set FORCE=1 to skip the prompt
# (useful for unattended installs — e.g. dotfiles scripts, CI).
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

# Compute the full list of destination paths this installer would write to.
destinations=(
    "$BIN_DIR/list-capture-targets.swift"
    "$BIN_DIR/screenshot-picker.sh"
)
for md in "$REPO_DIR/commands/"*.md; do
    destinations+=("$CMD_DIR/$(basename "$md")")
done

# Flag any destinations that already exist so the user isn't surprised by a
# silent clobber of their customizations.
conflicts=""
for f in "${destinations[@]}"; do
    [ -e "$f" ] && conflicts="${conflicts}  $f"$'\n'
done

if [ -n "$conflicts" ] && [ "${FORCE:-0}" != "1" ]; then
    echo "The following files already exist and will be overwritten:"
    printf "%s" "$conflicts"
    if [ ! -t 0 ]; then
        echo ""
        echo "Non-interactive shell detected. Re-run with FORCE=1 to overwrite, or remove those files first."
        exit 1
    fi
    printf "Continue? [y/N] "
    read -r answer
    case "$answer" in
        [yY]|[yY][eE][sS]) ;;
        *) echo "Aborted." >&2; exit 1 ;;
    esac
fi

echo "Installing helper scripts → $BIN_DIR"
cp "$REPO_DIR/bin/list-capture-targets.swift" "$BIN_DIR/"
cp "$REPO_DIR/bin/screenshot-picker.sh" "$BIN_DIR/"
chmod +x "$BIN_DIR/list-capture-targets.swift" "$BIN_DIR/screenshot-picker.sh"

echo "Installing slash commands → $CMD_DIR"
cp "$REPO_DIR/commands/"*.md "$CMD_DIR/"

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
