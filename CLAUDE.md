# claude-code-screenshot — repo notes

## What this is
A `/screenshot` slash command for [Claude Code](https://github.com/anthropics/claude-code) that captures any macOS screen or window via a native picker dialog. No crosshair, no leaving the terminal. Inspired by ChatGPT desktop's window-picker UX.

## Stack
- **Bash** — orchestrator (`bin/screenshot-picker.sh`)
- **Swift** — window/screen enumerator (`bin/list-capture-targets.swift`) using `CGGetActiveDisplayList` + `CGWindowListCopyWindowInfo`
- **AppleScript** — picker dialog via `osascript choose from list`
- **macOS `screencapture`** — capture by display index (`-D`) or window ID (`-l`)
- **No third-party dependencies.** Everything ships with macOS.

## Status
- **Repo:** `NatalieMiles/claude-code-screenshot` — **private**, will flip public after testing
- **Phase:** Functionally complete; in pre-launch hardening
- **Tracker:** `Projects 🧩/claude-code-screenshot` in Obsidian (launch checklist + decisions log)

## File map
```
.
├── bin/
│   ├── list-capture-targets.swift   # enumerator → outputs tab-separated `<id>\t<display>` lines (ID hidden from UI)
│   └── screenshot-picker.sh         # orchestrator → enumerate → osascript picker → screencapture
├── commands/
│   └── screenshot.md                # the slash command — captures, always Reads, responds like drag-drop
├── install.sh                       # copies files to ~/.claude/{bin,commands}
├── uninstall.sh                     # removes the installed files
├── README.md                        # public-facing pitch + install + tradeoffs
├── SECURITY.md                      # threat model, audit findings (L1/L2/L3 open), confirmed-safe list
├── LICENSE                          # MIT
└── AWESOME-CLAUDE-CODE-PR.md        # draft PR for awesome-claude-code submission
```

## Key decisions (and why)

| Decision | Why | Alternative considered |
|---|---|---|
| Use `osascript choose from list` for the picker | Unlimited items, scrollable, native macOS UX. Closest match to ChatGPT's picker. | `AskUserQuestion` (Claude Code's built-in) — capped at 4 options; couldn't fit screens + windows |
| Use `screencapture -l <windowID>` for window capture | Headless, no crosshair, works for any visible window | `screencapture -i` (interactive crosshair) — defeats the "no leaving terminal" goal |
| macOS-only, by design | The unified-picker UX depends on `osascript`. Generalizing to Linux (`slurp`) or Windows would mean different mechanisms per platform — losing the one-tool-one-UX benefit | Cross-platform shim with per-OS branching |
| Output to `/tmp/claude-screenshots/` | Auto-cleared by macOS, no clutter | `~/Library/Caches/...` — better privacy on multi-user systems (open improvement L1; see [SECURITY.md](SECURITY.md)) |
| Always exit 0 from `screenshot-picker.sh`; surface errors via stdout strings | Claude Code shows generic "shell command failed" on non-zero exit. Stdout strings let the slash command relay specific errors. | Use exit codes — but Claude Code's error UX hides the message |
| Require Screen Recording permission for the *terminal*, not the script | macOS Sequoia routes `screencapture -l/-D` through ScreenCaptureKit, which checks the *calling process*'s permission. Documented in README. | Sign + notarize a custom binary — too much overhead for a personal tool |

## Conventions
- All shell scripts pass `bash -n` syntax check before commit
- Helper scripts go in `bin/`, slash commands in `commands/` — mirrors install layout (`~/.claude/bin/`, `~/.claude/commands/`)
- Commit author: `Natalie Miles <nataliemiles@users.noreply.github.com>` (privacy-protected GitHub email)

## Pre-launch checklist (live in Obsidian)
See `Projects 🧩/claude-code-screenshot.md` for the active checklist. Summary:
- [ ] Test fresh-clone install on a clean `~/.claude/`
- [ ] Test on iTerm + Ghostty (not just Terminal.app)
- [ ] Test all capture flows (screen, frontmost window, background window, cancel)
- [ ] Apply security-review L1 (move output to `~/Library/Caches/`)
- [ ] Record demo GIF for README
- [ ] Flip repo to public
- [ ] Submit awesome-claude-code PR (draft already in repo)

## Known limitations
- Window titles are blank without Screen Recording permission — Quartz returns `nil` for `kCGWindowName` until granted (enumerator falls back to `WxH @ x,y` bounds so untitled windows are still distinguishable)
- macOS only

## Useful commands
```bash
# Test the enumerator
swift bin/list-capture-targets.swift

# Run the picker end-to-end (requires Screen Recording perm)
./bin/screenshot-picker.sh

# Reinstall after edits
./install.sh

# Verify shell syntax
bash -n bin/screenshot-picker.sh install.sh uninstall.sh
```
