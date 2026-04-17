#!/bin/bash
# Show native macOS picker for screens + windows, capture chosen target,
# print the resulting PNG path on stdout (or CANCELLED / ERROR: ...).
# Always exits 0 — errors are surfaced via stdout strings, not exit codes,
# so the caller can present them cleanly instead of a generic "shell failed".
set -uo pipefail

OUTDIR="$HOME/Library/Caches/claude-code-screenshot"
mkdir -p "$OUTDIR"
# User-only perms — the directory holds screenshots that may contain
# sensitive on-screen content, so other local accounts shouldn't read it.
chmod 700 "$OUTDIR" 2>/dev/null || true

# Enumerator output is tab-separated: <ID>\t<DISPLAY_STRING> per line.
# IDs: "s1".."sN" (screens), "w<id>" (windows), "HEADER" (dividers).
RAW=$(swift "$HOME/.claude/bin/list-capture-targets.swift" 2>/dev/null || true)

if [ -z "$RAW" ]; then
    echo "ERROR: No capture targets found (swift enumerator failed or returned nothing)"
    exit 0
fi

# Build the osascript list from the display column only.
LIST_AS=$(printf '%s\n' "$RAW" | awk -F'\t' 'NF==2 {
    s = $2
    gsub(/\\/, "\\\\", s)
    gsub(/"/, "\\\"", s)
    printf "\"%s\",", s
}' | sed 's/,$//')

# Default selection = first non-header row.
DEFAULT=$(printf '%s\n' "$RAW" | awk -F'\t' '$1 != "HEADER" && NF==2 {
    s = $2
    gsub(/\\/, "\\\\", s)
    gsub(/"/, "\\\"", s)
    print s; exit
}')

CHOSEN=$(osascript -e "choose from list {$LIST_AS} with prompt \"Capture target\" default items {\"$DEFAULT\"} OK button name \"Capture\" cancel button name \"Cancel\"" 2>/dev/null || true)

if [ "$CHOSEN" = "false" ] || [ -z "$CHOSEN" ]; then
    echo "CANCELLED"
    exit 0
fi

# Map the chosen display string back to its ID.
ID=$(printf '%s\n' "$RAW" | awk -F'\t' -v want="$CHOSEN" '$2 == want {print $1; exit}')

if [ "$ID" = "HEADER" ]; then
    echo "ERROR: You picked a section divider — pick a screen or window instead and try again."
    exit 0
fi

if [ -z "$ID" ]; then
    echo "ERROR: Could not match selection back to an ID: $CHOSEN"
    exit 0
fi

OUTFILE="$OUTDIR/ss-$(date +%Y%m%d-%H%M%S)-$RANDOM.png"
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

# Strip the leading type marker (🖥/★/▫️) before printing the label so the
# ack line reads cleanly — the marker is a picker-only visual cue.
CLEAN_LABEL="$CHOSEN"
CLEAN_LABEL="${CLEAN_LABEL#🖥  }"
CLEAN_LABEL="${CLEAN_LABEL#★  }"
CLEAN_LABEL="${CLEAN_LABEL#▫️  }"

echo "CAPTURED: $CLEAN_LABEL"
echo "$OUTFILE"
