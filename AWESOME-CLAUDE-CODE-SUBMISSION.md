# Submission info for awesome-claude-code

Copy-paste-ready content for submitting `claude-code-screenshot` to [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code).

> [!IMPORTANT]
> **Submissions are made via the web UI issue form, NOT a pull request.**
> The maintainer's [CONTRIBUTING.md](https://github.com/hesreallyhim/awesome-claude-code/blob/main/docs/CONTRIBUTING.md) is explicit: opening a PR or using `gh` CLI can trigger a temporary or permanent ban. Use a browser.

> [!WARNING]
> **Do not submit until the repo's first public commit is >7 days old.**
> This is a required checkbox in the form. Initial commit was **2026-04-17**, so the earliest safe submission date is **2026-04-24**. If "public commit" is interpreted as "commit while repo was public" (strict reading), wait until **2026-04-27** (1 week after the public flip on 2026-04-20).

## Submission form

https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml

## Field values (verified against the actual form YAML)

### Required fields

| Field | Value |
|---|---|
| **Title** | `[Resource]: /screenshot` |
| **Display Name** | `/screenshot` |
| **Category** *(dropdown)* | `Slash-Commands` |
| **Sub-Category** *(dropdown)* | `Slash-Commands: Miscellaneous` |
| **Primary Link** | `https://github.com/NatalieMiles/claude-code-screenshot` |
| **Author Name** | `Natalie Miles` |
| **Author Link** | `https://github.com/NatalieMiles` |
| **License** *(dropdown)* | `MIT` |

### Description (copy verbatim — form accepts 1–3 sentences, no emojis, no reader-addressing, descriptive not promotional)

> A `/screenshot` slash command for macOS that presents a native picker listing every display and every visible window, then captures the chosen target headlessly — no crosshair, no alt-tabbing. Designed for multi-monitor and window-heavy workflows where the system `Cmd+Shift+4` shortcut adds seconds of hunting before capture starts.

### Encouraged fields (not mandatory for slash commands, but speed up review)

**Validate Claims:**

> Clone the repo, run `./install.sh`, grant Screen Recording permission to your terminal (instructions in the README are per-host-app), then run `/screenshot` in Claude Code. The picker should list every active display (by model name) and every visible window (grouped under a Windows header, with the frontmost marked). Pick one; the capture writes to `~/Library/Caches/claude-code-screenshot/` and flows directly into the Claude conversation.

**Specific Task(s):**

> Capture a **background** window (not the currently-frontmost one) via the picker and confirm the resulting PNG is the chosen window, not the frontmost. This demonstrates the tool's main differentiator from `Cmd+Shift+4`: picking from a menu means the capture target doesn't have to be raised or foregrounded first.

**Specific Prompt(s):**

> `/screenshot`
>
> (Then select a backgrounded window — e.g., an Obsidian note or a Chrome tab behind the terminal — from the picker that appears.)

### Additional Comments (optional, but worth using for context)

> Built over ~4 days with three validation stages before submission: (1) end-to-end manual testing across Terminal.app, iTerm2, Ghostty, and VS Code's Claude Code extension, each requiring its own Screen Recording permission; (2) a security review of the picker pipeline (`SECURITY.md` documents the threat model and three low-severity findings, all closed); (3) a fresh-clone install test on a separate machine. Roadmap is visible in the 4 open GitHub issues — each has full design notes attached so contributors can pick them up without re-thinking scope.
>
> Re: "Could Opus build this in one session?" — the core functionality probably yes (it's under 200 lines of Bash + Swift). The differentiator is the polish: multi-host testing, security audit, tradeoff documentation, and the demo GIF.

### Checklist (5 required boxes — verify each)

- [ ] This resource hasn't already been submitted *(checked the current list: no existing screenshot-picker slash command)*
- [ ] Over one week since the first public commit *(verify date before submitting — see warning at top)*
- [ ] All provided links work and are publicly accessible
- [ ] I do NOT have any other open issues in this repository
- [ ] I am primarily composed of human-y stuff and not electrical circuits

## Why `Slash-Commands: Miscellaneous`

Walked the full dropdown in the form YAML. None of the more-specific Slash-Commands subcategories fit:

| Subsection | Fit? |
|---|---|
| Version Control & Git | No |
| Code Analysis & Testing | No |
| Context Loading & Priming | Adjacent — about code/file context, not visual captures |
| Documentation & Changelogs | No |
| CI / Deployment | No |
| Project & Task Management | No |
| **Miscellaneous** | **Best fit — catch-all for utility commands** |

If the maintainer prefers a different bucket or wants to propose a new subsection (e.g., "Input & Capture"), defer to them.

## Security disclosures (the maintainer explicitly checks for these)

| Concern | Status |
|---|---|
| Network calls besides Anthropic's | None — fully offline |
| Modifies shared system files | No — writes only to `~/Library/Caches/claude-code-screenshot/` (mode 700) |
| Telemetry | None |
| Requires `--dangerously-skip-permissions` | No |
| Elevated permissions | Only macOS Screen Recording (TCC), granted by user per host app |
| Auto-update or `npx @latest`-style self-updating | No |
| Security audit | [SECURITY.md](SECURITY.md) — 3 findings originally identified, all closed |
| Evidence for claims | Demo GIF in [README](README.md) |

## Self-evaluation (ran the maintainer's `evaluate-repository.md` prompt mentally)

| Criterion | Score | Justification |
|---|---|---|
| Code Quality | 9/10 | Bash `-n` syntax-checked; idiomatic Swift; clean separation (enumerator → picker → capture); purposeful comments |
| Security & Safety | 9/10 | No network; OUTDIR mode 700; regex-validated IDs; AppleScript escaping; bounded retention; threat model documented; 3/3 findings closed |
| Documentation | 10/10 | README covers value prop, demo GIF, install, permissions per host, usage, tradeoffs; SECURITY.md; CLAUDE.md decisions log; 4 designed issues |
| Functionality & Scope | 10/10 | Narrow, focused, demo-verified |
| Hygiene & Maintenance | 9/10 | Atomic commits with context-rich messages; MIT license; public author identity |
| **Overall** | **9.5/10** | Recommend |

**Red flags:** none.
**Discrepancies between declared and inferred behavior:** none (verified via code inspection).

## Pre-submission checklist

- [x] Public repo is live at https://github.com/NatalieMiles/claude-code-screenshot
- [x] README complete (value prop, install, permissions per host app, usage, tradeoffs, compatibility, contributing, license)
- [x] Demo GIF embedded
- [x] Issue tracker shows active roadmap (#1–#4 with full design notes)
- [x] Security review complete, no open findings
- [x] Read awesome-claude-code's [CONTRIBUTING.md](https://github.com/hesreallyhim/awesome-claude-code/blob/main/docs/CONTRIBUTING.md)
- [x] Read the form YAML to verify field options
- [x] Self-ran the maintainer's `evaluate-repository.md` prompt
- [ ] **Repo first public commit is >7 days old** (earliest: 2026-04-24, safer: 2026-04-27)
- [ ] **Submit the form** (the final step)

## What happens after submission

```
You submit the form
     ↓
Bot auto-validates fields (URLs resolve, no duplicates, description length, checklist)
     ↓
Maintainer reviews (no SLA — awesome lists are passion projects)
     ↓
Maintainer runs their own Claude Code evaluation using
.claude/commands/evaluate-repository.md
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

## Tone guidance

From the maintainer's CONTRIBUTING.md:
- Claims must be evidence-based → your demo GIF + SECURITY.md cover this
- Don't oversell — understated and accurate beats hype
- Lead with the gap (no screenshot/window-picker entry in the current list), not feature count
- Mention macOS-only upfront so it doesn't look like an oversight
