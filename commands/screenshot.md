---
description: Take a screenshot via native macOS picker and attach it to the conversation
argument-hint: [optional question about the screenshot]
allowed-tools: Bash(~/.claude/bin/screenshot-picker.sh:*), Read
---

Capture a screenshot via a native macOS picker (all screens + every visible window in one scrollable list) and attach it to the conversation. After capture, treat the image exactly as if the user had drag-dropped it — Read it, then respond based on their intent.

Step 1 — show the picker and capture.

!`~/.claude/bin/screenshot-picker.sh`

Step 2 — handle the result above:
- `CANCELLED` → tell the user the capture was cancelled and stop.
- `ERROR: ...` → relay the error to the user and stop.
- Otherwise the output has two lines: `CAPTURED: <label>` (what the user picked) and an absolute path to the PNG.

Step 3 — Read the PNG with the Read tool, then respond as you would to a drag-dropped image:

- **If `$ARGUMENTS` is non-empty** → treat it as the user's question/request about the image and answer directly.
- **Else if the conversation already has context** that makes the user's intent obvious (e.g. they're mid-debug, asking about a UI issue, reviewing a design) → act on that context.
- **Else** → briefly describe what's in the image in one or two sentences and stop. No trailing question, no prompt for input.

In all cases, lead with a short acknowledgement that names what was captured (e.g. "Captured Obsidian window.") before the substantive response.
