---
description: Take a screenshot via native macOS picker (all screens + windows in one list)
argument-hint: [optional note about what's in the screenshot]
allowed-tools: Bash(~/.claude/bin/screenshot-picker.sh:*), Read
---

Take a screenshot using the native macOS picker. The picker shows all 3 screens and every visible window in one scrollable dialog — pick one, capture happens automatically, no crosshair, no leaving the terminal.

Step 1 — show the picker and capture.

!`~/.claude/bin/screenshot-picker.sh`

Step 2 — handle the result above:
- `CANCELLED` → tell the user the capture was cancelled and stop.
- `ERROR: ...` → relay the error to the user and stop.
- Otherwise the output is an absolute path to a PNG — hold onto it for step 3.

Step 3 — respond based on context:
- If `$ARGUMENTS` was passed, Read the PNG with the Read tool and treat `$ARGUMENTS` as the user's question/request about the screenshot.
- Otherwise, do NOT Read the PNG yet. Reply with a one-line acknowledgement naming the file (e.g. "Captured `ss-20260417-143022.png`. What would you like me to do with it?") and stop. On the user's next message, Read the PNG and respond with their context in mind.
