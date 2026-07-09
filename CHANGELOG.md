# Changelog

## 1.0.0

First public release — the kit as a complete, self-contained starter.

**The protocol.** A three-role division of authority — you decide, Opus (Architect)
thinks, Sonnet (Operative) does the routine — with a single hard line between userspace
and system. In your home (`~/`) the AI works without ceremony; every root action passes a
four-beat **grant ritual** (request → your yes → *your* password → immediate revoke). The
AI never holds standing root. Full model in `THE-PROTOCOL.md`, root policy in
`ROOT-POLICY.md`.

**Safety in two layers, honestly bounded.** Inside the kit's own commands the only path to
root is `run_root()` (`bin/kit-lib.sh`), which prints the exact command + reason, screens a
denylist (`rm -rf /`, `mkfs`, `dd of=/dev/…`, fork bombs, `chmod -R 777 /`,
`--no-preserve-root`), and asks — `--auto` auto-confirms green only, yellow/red still ask.
Because the kit can't police `sudo` calls made *around* it, two layers sit on top: an
allowlist with no blanket-`sudo` grant (`config/claude-allowlist.json`) and a guard hook
(`hooks/deny-destructive.sh`) that cuts destructive commands from any AI action. The
boundary is stated plainly rather than overclaimed.

**Onboarding.** `BOOTSTRAP.md` is the script Claude runs for a newcomer: probe the machine,
short intake, offer skills one at a time (nothing installed without a "yes"), wire commands,
lay down the layout. `START-HERE.md` is the human-facing three-step entry.

**Six skills** — `stats-lab`, `data-wrangle`, `research-helper`, `linux-tutor`,
`system-tune`, `man` — installed by copying into `~/.claude/skills/` on consent.

**Commands** — `update` (system update + security check), `fix` (self-healing repairs
for disk/DNS/Wi-Fi/packages/services, growing its own known-issues registry via
`kb/known-issues.sh`), `where` (a map of the laptop), `recall` (search notes + logs),
`kit-help` (cheatsheet, shown on terminal open), `kit-guide` (a browser dossier bound to
Super+\ via `kit-keybind`).

**Clean layout.** A typed filesystem + memory kept map-not-dump (`conventions/layout.md`) —
[agent-atlas](https://github.com/zzallirog/agent-atlas) folded down to a single machine.
`AGENTS.md` is the navigator so Claude enters by a route instead of reading the whole kit.

**Handshake.** The kit's own discipline turned on itself: verify your copy by
`git rev-parse HEAD` against the commit GitHub shows — a repo can't fake its own hash from
the inside.

**Platform.** Linux, single machine, designed for Opus (runs on Sonnet more simply). MIT
licensed.
