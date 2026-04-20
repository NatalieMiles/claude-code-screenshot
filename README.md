# claude-code-screenshot

A `/screenshot` slash command for [Claude Code](https://github.com/anthropics/claude-code) that lets you pick *exactly which* screen or window to send to Claude — from a native macOS menu listing every display and visible window on your Mac. No crosshair, no alt-tabbing, no leaving the terminal.

Built for multi-monitor setups and window-heavy workflows where `Cmd+Shift+4` means seconds of hunting before you even start capturing.

Inspired by ChatGPT desktop's "Take screenshot → pick a window" flow, ported to Claude Code's CLI.

![/screenshot demo: pick a window from a native macOS menu, capture flows directly into Claude](https://github.com/user-attachments/assets/8640888b-5a6a-4fd1-a47a-11b963df8632)

## Why not just `Ctrl+V`?

Claude Code already supports `Ctrl+V` to paste images from the clipboard, and that's enough most of the time. Reach for `/screenshot` when:

- You have 3+ monitors and need to send Claude *that specific* display without dragging across them
- You have 12 Chrome windows open and want the *right* one (without getting it wrong on the first try)
- You're capturing the *same* window repeatedly and want one keystroke instead of three

## How it works

Run `/screenshot` in Claude Code. A native macOS dialog appears listing every screen and every visible window, grouped by type:

```
┌─ Capture target ───────────────────────────────┐
│ ─── SCREENS ───                                │
│ 🖥  LG SDQHD (1) — 2560×1440 [main]            │
│ 🖥  VX2485 Series — 1920×1080                  │
│ 🖥  LG SDQHD (2) — 2560×1440                   │
│ ─── WINDOWS ───                                │
│ ★  Terminal — Test Claude Code screenshot...   │
│ ▫️  ChatGPT — ChatGPT                          │
│ ▫️  Obsidian — Daily Note                      │
│ ▫️  Google Chrome — Calendar                   │
│ ...                                            │
│              [Cancel]   [Capture]              │
└────────────────────────────────────────────────┘
```

Pick one → it captures instantly → Claude prints a short `Captured <target>` acknowledgement back in the conversation. Markers: `🖥` = screen, `★` = frontmost window, `▫️` = other windows. Screen entries use each display's actual model name (via `NSScreen.localizedName`), so users with multiple monitors can tell them apart.

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

macOS Sequoia (15+) requires the calling process — whatever app is actually running Claude Code — to have explicit Screen Recording permission for non-interactive `screencapture` flags (`-l <windowID>`, `-D <displayID>`).

1. **System Settings → Privacy & Security → Screen & System Audio Recording**
2. Click the **`+`** button at the bottom of the list
3. Press `Cmd+Shift+G`, then paste the path for whichever app is running Claude Code:
   - **Terminal.app:** `/System/Applications/Utilities/Terminal.app`
   - **iTerm2:** `/Applications/iTerm.app`
   - **Ghostty:** `/Applications/Ghostty.app`
   - **Claude Code VS Code extension:** `/Applications/Visual Studio Code.app` (Visual Studio Code hosts the extension, so VS Code itself is the process macOS checks)

   Press Enter, click **Open**.
4. Toggle the entry **on**
5. **Fully quit that app (`Cmd+Q`)** and reopen it. TCC permissions only attach when the process starts.

If you switch which app you run Claude Code in later, repeat for the new one — each app gets its own permission entry.

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
| 3. Capture | `screencapture -l <windowID>` or `screencapture -D <displayIndex>` | Headless capture of the chosen target. Writes a PNG to `~/Library/Caches/claude-code-screenshot/` (mode 700 — readable only by you). |
| 4. Attach | Claude Code's `Read` tool | Reads the PNG into the conversation. |

## Tradeoffs

- **macOS only.** The whole UX rests on macOS's native picker dialog and `screencapture`'s window-by-ID flag. Generalizing to Linux (`slurp`/`grim`) or Windows would mean a different dialog mechanism per platform — losing the "one tool, one UX" benefit.
- **Window titles depend on Screen Recording permission.** Without it, you get `Obsidian` instead of `Obsidian — Daily Note.md`. The enumerator falls back to showing window bounds (`Google Chrome — 1440×900 @ 100,0`) so multiple untitled windows of the same app stay distinguishable, but full titles are still better.
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
