# Draft entry for awesome-claude-code

This is the draft PR contribution for [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code). Submit *after* the public repo is up and the URL below resolves.

## Where it goes

The repo's `README.md` has a `## Slash-Commands` section (or similar — verify current section names before submitting). Look for an existing subsection that fits, or propose one if needed:

- **Best fit candidate:** Under `Slash-Commands → System & Workflow` or `Slash-Commands → Utilities`
- **Fallback:** Open an issue first to ask the maintainer where it belongs (less drive-by, more collaborative)

## PR description (copy-paste)

```markdown
## What

Add `claude-code-screenshot` — a `/screenshot` slash command for macOS that captures any screen or window via a native picker dialog, no crosshair, no leaving the terminal.

## Why

Claude Code's built-in `Ctrl+V` clipboard paste covers most cases, but for users with multiple monitors or many open windows, the existing flow (alt-tab → region screenshot tool → drag-select → return) is friction. This command replaces that with one keystroke + one click in a native macOS picker that lists every screen and every visible window in one scrollable dialog (similar UX to ChatGPT desktop's "take screenshot" flow).

## How it differs from existing entries

I checked the current index — there's no screenshot or screen-capture entry under Slash-Commands. The closest adjacent tooling I found in the broader ecosystem uses `screencapture -s` (interactive crosshair region select) or watches `~/Desktop` for new files. None present a unified picker of screens + windows, and none use `screencapture -l <windowID>` to capture a specific window headlessly.

## Scope honesty

macOS-only by design. The picker UX depends on `osascript choose from list` and the headless capture depends on `screencapture -l/-D`, both Mac-specific. I considered cross-platform shimming and decided against it — the unified-picker UX is what makes it good, and Linux/Windows equivalents would require materially different mechanisms.
```

## Suggested entry text (the actual line to add to the README)

Match the formatting style already used in the file. Likely something like:

```markdown
- [claude-code-screenshot](https://github.com/NatalieMiles/claude-code-screenshot) — `/screenshot` command for macOS. Pick any screen or window from a native picker dialog and attach the capture without leaving the terminal. Multi-monitor friendly.
```

## Pre-submission checklist

- [ ] Public repo is up at the URL referenced above
- [ ] README.md is complete with install instructions, screenshots/demo, license
- [ ] At least one issue or release tag exists (signals the project isn't a one-day throwaway)
- [ ] Re-read awesome-claude-code's CONTRIBUTING.md (if it exists) for style rules
- [ ] Verify the section name in their README hasn't changed — fork is fresh
- [ ] Keep the PR description focused; let the README do the heavy lifting

## Tone notes

- Don't oversell. The maintainer sees a lot of submissions; understated and accurate beats hype.
- Lead with the gap (no screenshot entry exists), not the feature list.
- Mention macOS-only upfront so reviewers don't think it's an oversight.
