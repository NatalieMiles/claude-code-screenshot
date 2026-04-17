# Security

## Reporting a vulnerability

If you find a security issue, please email the maintainer (see [README](README.md#about) for contact) rather than opening a public issue. I'll respond within a few days.

## Threat model

This tool runs entirely on your local Mac. The most realistic threat is an attacker who controls a **window title** on your machine — for example, getting you to open a webpage, document, or terminal session whose title contains crafted characters — and using that title to inject commands into the picker pipeline.

Everything in this codebase has been audited against that threat model.

## Review scope

| Component | Reviewed for |
|---|---|
| `bin/list-capture-targets.swift` | Output sanitization, error handling, scope of macOS APIs called |
| `bin/screenshot-picker.sh` | Shell injection, AppleScript injection, command substitution in interpolated variables, ID validation before passing to `screencapture`, output filename safety, race conditions, symlink attacks |
| `commands/screenshot.md` | Allowed-tools scope, no leakage of sensitive paths |
| `install.sh` / `uninstall.sh` | File copy safety, no fetched-and-executed code, no privilege escalation |

## Findings

| ID | Severity | Issue | Status | Fix |
|---|---|---|---|---|
| L1 | Low | PNG output directory is `/tmp/claude-screenshots/` which is world-readable on the Mac. Captures of sensitive content can be read by other local users on multi-user systems. | **Open** | Change `OUTDIR` in `screenshot-picker.sh` to `"$HOME/Library/Caches/claude-code-screenshot"` (user-only readable). One-line change + doc update. |
| L2 | Low (UX, not security) | Two captures within the same second overwrite each other (timestamp resolution = 1 second). | **Open** | Append `$$` (process ID) or milliseconds to the filename: `ss-$(date +%Y%m%d-%H%M%S)-$$.png`. |
| L3 | Low | `install.sh` silently overwrites existing files in `~/.claude/`, which could clobber a user's customizations. | **Open** | Add a `[y/N]` confirmation prompt when destination files already exist. |

**No critical, high, or medium findings.**

## What was confirmed safe

- ✅ **No secrets in repo** — no API keys, tokens, or internal-only paths
- ✅ **No network calls** — script is fully offline
- ✅ **No privilege escalation** — runs as the invoking user, no `sudo`, no setuid
- ✅ **No `eval` or dynamically constructed commands** — every command path is literal
- ✅ **No `curl | bash`** in `install.sh` — copies local files only
- ✅ **AppleScript injection blocked** — window titles flowing into `osascript` have `\` and `"` escaped via `awk`. Bash variable expansion is one-pass and does not re-trigger command substitution on expanded values, so `$(...)` inside a malicious title is passed as a literal string to AppleScript, where it has no shell-execution meaning.
- ✅ **`screencapture` argument injection blocked** — the user's chosen label is passed through `grep -oE '^\[(s|w)[0-9]+\]'` and then `[[ "$ID" =~ ^s([0-9]+)$ ]]`, ensuring only digits reach `screencapture -D` / `-l`.
- ✅ **No symlink-attack window** — `/tmp/claude-screenshots/` is created and owned by the invoking user; the sticky bit on `/tmp` prevents same-host attackers from substituting the directory.

## Methodology

The audit traced the data flow at every boundary: Quartz API → Swift output → bash variable → AppleScript string → bash variable → `screencapture` argument. At each boundary, the question was: *"if a window title contained the worst possible payload, what would happen?"* Each escape, regex, and quoting boundary was verified to neutralize the threat.

## Re-audit triggers

Re-run this review if any of the following change:

- The picker mechanism changes (e.g., switching off `osascript`)
- Output filename or directory becomes user-controlled
- `screencapture` arguments become user-controlled beyond the validated `[s|w][0-9]+` pattern
- Any new helper script is added to `bin/`
- The slash command's `allowed-tools` is broadened
