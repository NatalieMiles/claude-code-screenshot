#!/bin/bash
# Show native macOS picker for screens + windows, capture chosen target,
# print the resulting PNG path on stdout (or CANCELLED / ERROR: ...).
# Always exits 0 — errors are surfaced via stdout strings, not exit codes,
# so the caller can present them cleanly instead of a generic "shell failed".
set -uo pipefail

OUTDIR="/tmp/claude-screenshots"
mkdir -p "$OUTDIR"

TARGETS=$(swift "$HOME/.claude/bin/list-capture-targets.swift" 2>/dev/null | grep -E '^\s*\[(s|w)' | sed 's/^\s*//' || true)

if [ -z "$TARGETS" ]; then
    echo "ERROR: No capture targets found (swift enumerator failed or returned nothing)"
    exit 0
fi

LIST_AS=$(printf '%s\n' "$TARGETS" | awk '{
    gsub(/\\/, "\\\\");
    gsub(/"/, "\\\"");
    printf "\"%s\",", $0
}' | sed 's/,$//')

DEFAULT=$(printf '%s\n' "$TARGETS" | head -1 | awk '{
    gsub(/\\/, "\\\\");
    gsub(/"/, "\\\"");
    print
}')

CHOSEN=$(osascript -e "choose from list {$LIST_AS} with prompt \"Capture target\" default items {\"$DEFAULT\"} OK button name \"Capture\" cancel button name \"Cancel\"" 2>/dev/null || true)

if [ "$CHOSEN" = "false" ] || [ -z "$CHOSEN" ]; then
    echo "CANCELLED"
    exit 0
fi

ID=$(printf '%s' "$CHOSEN" | grep -oE '^\[(s|w)[0-9]+\]' | tr -d '[]' || true)

if [ -z "$ID" ]; then
    echo "ERROR: Could not parse ID from selection: $CHOSEN"
    exit 0
fi

OUTFILE="$OUTDIR/ss-$(date +%Y%m%d-%H%M%S).png"
SC_ERR=""

if [[ "$ID" =~ ^s([0-9]+)$ ]]; then
    SC_ERR=$(screencapture -x -D "${BASH_REMATCH[1]}" "$OUTFILE" 2>&1) || true
elif [[ "$ID" =~ ^w([0-9]+)$ ]]; then
    SC_ERR=$(screencapture -x -o -l "${BASH_REMATCH[1]}" "$OUTFILE" 2>&1) || true
else
    echo "ERROR: Unknown ID format: $ID"
    exit 0
fi

if [ ! -f "$OUTFILE" ]; then
    if echo "$SC_ERR" | grep -qiE 'could not create image|permission|denied'; then
        echo "ERROR: PERMISSION_DENIED — screencapture needs Screen Recording permission for your terminal app. Fix: System Settings → Privacy & Security → Screen & System Audio Recording → click [+] and add your terminal (Terminal.app or iTerm), then quit and reopen it. Raw error: $SC_ERR"
    else
        echo "ERROR: Capture failed: $SC_ERR"
    fi
    exit 0
fi

echo "$OUTFILE"
