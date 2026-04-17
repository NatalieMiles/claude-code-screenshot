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
| L1 | Low | PNG output directory was `/tmp/claude-screenshots/` which is world-readable on the Mac. Captures of sensitive content could be read by other local users on multi-user systems. | **Fixed** | Moved `OUTDIR` in `screenshot-picker.sh` to `$HOME/Library/Caches/claude-code-screenshot` and applied `chmod 700` on creation. User-only readable. |
| L2 | Low (UX, not security) | Two captures within the same second overwrote each other (timestamp resolution = 1 second). | **Fixed** | Output filename now appends `$RANDOM` alongside the timestamp: `ss-YYYYMMDD-HHMMSS-$RANDOM.png`. Collision-proof at human-scale capture rates. |
| L3 | Low | `install.sh` silently overwrote existing files in `~/.claude/`, which could clobber a user's customizations. | **Fixed** | Installer now lists every destination that would be overwritten and prompts `[y/N]` before proceeding. Aborts in non-TTY contexts unless `FORCE=1` is set. |

**No critical, high, or medium findings. All low findings closed.**

## What was confirmed safe

- ✅ **No secrets in repo** — no API keys, tokens, or internal-only paths
- ✅ **No network calls** — script is fully offline
- ✅ **No privilege escalation** — runs as the invoking user, no `sudo`, no setuid
- ✅ **No `eval` or dynamically constructed commands** — every command path is literal
- ✅ **No `curl | bash`** in `install.sh` — copies local files only
- ✅ **AppleScript injection blocked** — window titles flowing into `osascript` have `\` and `"` escaped via `awk` before being interpolated into the `choose from list` payload. Bash variable expansion is one-pass and does not re-trigger command substitution on expanded values, so `$(...)` inside a malicious title is passed as a literal string to AppleScript, where it has no shell-execution meaning.
- ✅ **`screencapture` argument injection blocked** — the enumerator emits IDs in a tab-separated first column (`s1`..`sN`, `w<digits>`, or `HEADER`) that never mixes with window titles. After the user picks a display string, bash looks up the ID via `awk -F'\t' '$2 == want {print $1}'`, then validates with `[[ "$ID" =~ ^s([0-9]+)$ ]]` / `^w([0-9]+)$` before passing the matched digits to `screencapture -D` / `-l`. A window title cannot reach the ID column.
- ✅ **No symlink-attack window** — `$HOME/Library/Caches/claude-code-screenshot/` is created with `mkdir -p` then `chmod 700`, so it's owned by the invoking user with no other-user access. An attacker on the same Mac would need to already control the user's HOME to substitute the directory.

## Methodology

The audit traced the data flow at every boundary: Quartz API → Swift output → bash variable → AppleScript string → bash variable → `screencapture` argument. At each boundary, the question was: *"if a window title contained the worst possible payload, what would happen?"* Each escape, regex, and quoting boundary was verified to neutralize the threat.

## Re-audit triggers

Re-run this review if any of the following change:

- The picker mechanism changes (e.g., switching off `osascript`)
- Output filename or directory becomes user-controlled
- `screencapture` arguments become user-controlled beyond the validated `[s|w][0-9]+` pattern
- Any new helper script is added to `bin/`
- The slash command's `allowed-tools` is broadened
