# kit-claude — navigator (a map of the kit, not a dump)

> A Claude Code starter kit: newbie onboarding + a working method + a clean layout
> of files and memory. This map exists so Claude enters by a route instead of
> reading the whole kit.

## TL;DR (30 seconds)
- **What:** a ready kit — roles/safety, skills, commands, layout.
- **Start:** the human reads `START-HERE.md`; Claude reads `BOOTSTRAP.md` (the onboarding script).
- **Spirit:** you decide · Opus plans · Sonnet does the routine; root only through a grant.

## Kit map
    BOOTSTRAP.md      — the script for Claude (onboarding steps)
    START-HERE.md     — the entry point for the human
    THE-PROTOCOL.md   — roles (owner / architect / operative) + temporary root
    ROOT-POLICY.md    — the full root policy
    CONVENTIONS.md    — working habits (fish · projects · kb · where/recall)
    conventions/      — layout.md (the layout, clean for Claude) · security-root.md
    skills/           — stats-lab·data-wrangle·research-helper·linux-tutor·system-tune·man
    bin/              — kit-install·update·fix·where·recall·kit-guide·kit-keybind
    hooks/            — deny-destructive.sh (guard hook)
    kb/               — known-issues.sh (self-healing fix) · README.md
    tweaks/           — CATALOG.md (system tweaks)
    config/           — claude-allowlist · fastfetch · layout.example
    guide/            — kit-guide.html (the dossier, Super+\)

## Invariants (do not break)
1. root only through the grant ritual; the assistant holds no standing root.
2. Destructive commands are cut by the guard hook (`hooks/deny-destructive.sh`).
3. Skills are installed by copying into `~/.claude/skills/` — only with consent.

## Fast paths
- **install the kit** → `bash bin/kit-install`
- **understand roles/safety** → `THE-PROTOCOL.md` → `conventions/security-root.md`
- **set up the clean layout** → `conventions/layout.md` (+ the "layout" step in `BOOTSTRAP.md`)
- **add a skill** → `skills/<name>/` (SKILL.md + README.md)
- **a new known breakage for `fix`** → `kb/known-issues.sh` (format in `kb/README.md`)

## What lives outside
- The layout concept (theory) → agent-atlas; this kit is its working implementation.
- The user's session memory lives in their `~/` (CLAUDE.md · kb · memory), not in the kit.

## Self-update
Structure / skills / commands changed → fix this map.
