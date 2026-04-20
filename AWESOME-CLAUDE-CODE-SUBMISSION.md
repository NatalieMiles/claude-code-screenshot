# Submission info for awesome-claude-code

Copy-paste-ready content for submitting `claude-code-screenshot` to [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code).

> [!IMPORTANT]
> **Submissions are made via the web UI issue form, NOT a pull request.**
> The maintainer's [CONTRIBUTING.md](https://github.com/hesreallyhim/awesome-claude-code/blob/main/docs/CONTRIBUTING.md) is explicit: opening a PR or using `gh` CLI can trigger a temporary or permanent ban. Use a browser.

## Submission form

https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml

## Field values

| Field | Value |
|---|---|
| **Display Name** | `/screenshot` |
| **Category** | Slash-Commands |
| **Sub-Category** | Miscellaneous |
| **Primary Link** | `https://github.com/NatalieMiles/claude-code-screenshot` |
| **Author Name** | Natalie Miles |
| **Author Link** | `https://github.com/NatalieMiles` |
| **License** | MIT |

### Description (1–2 sentences, copy verbatim)

> A `/screenshot` slash command for macOS that lets you pick exactly which screen or window to send to Claude from a native picker listing every display and visible window. No crosshair, no alt-tabbing — designed for multi-monitor and window-heavy workflows where the system `Cmd+Shift+4` shortcut means seconds of hunting before capture starts.

## Why "Slash-Commands → Miscellaneous"

Walked the actual Slash-Commands subsections in the current awesome-claude-code README. None fit cleanly:

| Subsection | Fit? |
|---|---|
| General | Too generic |
| Version Control & Git | No |
| Code Analysis & Testing | No |
| Context Loading & Priming | Adjacent, but this category is about code/file context, not visual captures |
| Documentation & Changelogs | No |
| CI / Deployment | No |
| Project & Task Management | No |
| **Miscellaneous** | **Best fit — catch-all for utility commands** |

If the maintainer prefers a different bucket or wants to propose a new subsection, defer to them.

## Security disclosures (the maintainer explicitly checks for these)

| Concern | Status |
|---|---|
| Network calls besides Anthropic's | None — fully offline |
| Modifies shared system files | No — writes only to `~/Library/Caches/claude-code-screenshot/` (mode 700) |
| Telemetry | None |
| Requires `--dangerously-skip-permissions` | No |
| Security audit | See [SECURITY.md](SECURITY.md) — 3 findings originally identified, all closed |
| Evidence for claims | Demo GIF embedded in the main [README](README.md) |

If the form has a notes or additional-context field, link reviewers to [SECURITY.md](SECURITY.md) directly — it's the fastest way for them to verify the threat model and closed findings.

## Pre-submission checklist

- [x] Public repo is live at https://github.com/NatalieMiles/claude-code-screenshot
- [x] README complete (value prop, install, permissions per host app, usage, tradeoffs, compatibility, contributing, license)
- [x] Demo GIF embedded (proves the feature works)
- [x] Issue tracker shows active roadmap (#1–#4 with full design notes)
- [x] Security review complete, no open findings
- [x] Read awesome-claude-code's [CONTRIBUTING.md](https://github.com/hesreallyhim/awesome-claude-code/blob/main/docs/CONTRIBUTING.md)
- [x] Identified correct category (Slash-Commands → Miscellaneous)
- [ ] **Submit the form** (the only remaining step)

## What happens after you submit

```
You submit the form
     ↓
Bot auto-validates fields (URLs resolve, no duplicates, description length)
     ↓
Maintainer reviews (no SLA — awesome lists are passion projects)
     ↓
If approved: bot auto-creates a PR to add the entry. You don't touch it.
     ↓
PR merges → bot opens a notification issue on your repo
     ↓
Optionally, add the "Mentioned in Awesome Claude Code" badge to your README:
```

```markdown
[![Mentioned in Awesome Claude Code](https://awesome.re/mentioned-badge-flat.svg)](https://github.com/hesreallyhim/awesome-claude-code)
```

## Tone guidance (for the description / any free-text)

From the maintainer's CONTRIBUTING.md:
- Claims must be evidence-based — your demo GIF covers this
- Don't oversell — understated and accurate beats hype
- Lead with the gap (no screenshot/window-picker entry in the current list), not a feature list
- Mention macOS-only upfront so it doesn't look like an oversight
