# claude-code-screenshot

A `/screenshot` slash command for [Claude Code](https://github.com/anthropics/claude-code) that captures any screen or window via a native macOS picker — no crosshair, no leaving the terminal.

Inspired by ChatGPT desktop's "Take screenshot → pick a window" flow, ported to Claude Code's CLI.

## Why

Claude Code already supports `Ctrl+V` to paste images from the clipboard. That's enough most of the time. This command is for the multi-monitor, multi-window cases where:

- You don't want to alt-tab to a region screenshotter, drag-select, then come back
- You're capturing the *same* window repeatedly and want one keystroke instead of three
- You have 3 monitors and need to specify *which* one without dragging across them

## How it works

Run `/screenshot` in Claude Code. A native macOS dialog appears listing every screen and every visible window:

```
┌─ Capture target ─────────────────────┐
│ [s1] Screen 1 — 2560×1440 [main]     │
│ [s2] Screen 2 — 1920×1080            │
│ [s3] Screen 3 — 2560×1440            │
│ [w3308] ★ Terminal                   │
│ [w589]  ChatGPT                      │
│ [w1637] Obsidian — Daily Note        │
│ [w224]  Google Chrome — Calendar     │
│ ...                                  │
│            [Cancel]   [Capture]      │
└──────────────────────────────────────┘
```

Pick one → it captures instantly → the PNG is attached to the conversation. The `★` marks the frontmost window.

## Usage

```
/screenshot                                 # pick target, capture, Claude Reads + responds to context
/screenshot what's wrong with this error?   # same, but answer a specific question
```

`/screenshot` behaves exactly like **drag-dropping an image** into the conversation: Claude Reads it and responds based on whatever context the conversation has — any question you passed as `$ARGUMENTS`, or the thread you're already in (mid-debug, reviewing a design, etc.). If neither applies, Claude gives a brief one-line description.

**Token cost per capture:** ~$0.01–0.07 depending on image size and model (roughly `pixels / 750` image tokens). If you need to capture *without* spending tokens (save the PNG for later), use `screencapture -i` directly from a shell — this command is purpose-built for "get the image in front of Claude now."

## Install

```bash
git clone https://github.com/NatalieMiles/claude-code-screenshot.git
cd claude-code-screenshot
./install.sh
```

The installer copies three files into `~/.claude/`:

- `~/.claude/commands/screenshot.md` — the slash command
- `~/.claude/bin/screenshot-picker.sh` — orchestrator (enumerate → picker → capture)
- `~/.claude/bin/list-capture-targets.swift` — Swift script that lists screens + windows with their CoreGraphics IDs

## Required: grant Screen Recording permission

macOS Sequoia (15+) requires the calling process — your terminal — to have explicit Screen Recording permission for non-interactive `screencapture` flags (`-l <windowID>`, `-D <displayID>`).

1. **System Settings → Privacy & Security → Screen & System Audio Recording**
2. Click the **`+`** button at the bottom of the list
3. Press `Cmd+Shift+G`, type `/System/Applications/Utilities/Terminal.app` (or the path to your terminal — iTerm, Ghostty, etc.), press Enter, click **Open**
4. Toggle the entry **on**
5. **Fully quit your terminal (`Cmd+Q`)** and reopen it. TCC permissions only attach when the process starts.

If you skip this, the picker still appears, but the capture fails with a clear `PERMISSION_DENIED` message that tells you exactly what to do.

## Uninstall

```bash
./uninstall.sh
```

(Doesn't touch your Screen Recording permission — remove that manually in System Settings if you want.)

## How it works under the hood

| Step | Tool | What it does |
|---|---|---|
| 1. Enumerate | `list-capture-targets.swift` | Calls `CGGetActiveDisplayList` for screens and `CGWindowListCopyWindowInfo` for visible windows. Outputs one line per target with a stable ID. |
| 2. Pick | `osascript choose from list` | macOS's built-in modal picker — scrollable, keyboard-navigable, returns the chosen label. |
| 3. Capture | `screencapture -l <windowID>` or `screencapture -D <displayIndex>` | Headless capture of the chosen target. Writes a PNG to `/tmp/claude-screenshots/`. |
| 4. Attach | Claude Code's `Read` tool | Reads the PNG into the conversation. |

## Tradeoffs

- **macOS only.** The whole UX rests on macOS's native picker dialog and `screencapture`'s window-by-ID flag. Generalizing to Linux (`slurp`/`grim`) or Windows would mean a different dialog mechanism per platform — losing the "one tool, one UX" benefit.
- **Window titles depend on Screen Recording permission.** Without it, you get `[w1637] Obsidian` instead of `[w1637] Obsidian — Daily Note.md`. Apps you have multiple windows of (Chrome especially) become hard to disambiguate.
- **Not a replacement for `Ctrl+V`.** That flow is still better for ad-hoc clipboard pastes, design mockups dragged in from Figma, etc. Use this one when you're capturing live screen state.

## Compatibility

- macOS 13 (Ventura) or newer; tested on macOS 26
- Claude Code v2.0+
- Swift 5.0+ (ships with macOS)
- No third-party dependencies

## Contributing

Issues and PRs welcome. Most likely directions:

- Filter or group windows by app when there are many of them
- Optional Hammerspoon hotkey wrapper to invoke it without typing `/screenshot`
- Configurable output directory

## License

MIT — see [LICENSE](LICENSE).

## About

Built by [Natalie Miles](https://nataliemiles.me/) — a product manager who writes code on the side. Find more at [nataliemiles.me](https://nataliemiles.me/) or [LinkedIn](https://www.linkedin.com/in/natalieamiles).
