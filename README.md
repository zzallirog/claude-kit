# claude-kit

> A ready-to-run Claude Code starter kit — roles & safety, skills, commands, and a
> clean filesystem/memory layout. What took one person three months, packaged so a
> newcomer gets going in five minutes.

Built for a specific beginner (a psychology student on Linux); the shape is general —
the persona is just the worked example.

## Quick start
```
cd claude-kit
claude
```
Then tell Claude:
> read BOOTSTRAP.md and begin

Claude runs the onboarding: probes your machine, asks what you need, offers skills
one at a time (installs nothing without your "yes"), sets up commands, and lays down
a clean layout.

## The protocol (who's in charge)
**You decide · Opus thinks · Sonnet does — and the key is yours.** Home (`~/`) is
free; the system (root) moves only through a one-time grant that *you* confirm with
your password. Full model: [THE-PROTOCOL.md](THE-PROTOCOL.md). A guard hook
(`hooks/deny-destructive.sh`) cuts destructive commands from any AI action.

## What's inside
- **Skills** — stats-lab · data-wrangle · research-helper · linux-tutor · system-tune · man
- **Commands** — `update` · `fix` · `where` · `recall` · `kit-help` · `kit-guide` (Super+\\)
- **Layout** — a clean filesystem + typed memory, kept [clean for Claude](conventions/layout.md): a map not a dump, load only what's needed.
- **Self-healing fix** — `fix` grows its own known-issues registry over time.

## Map
[AGENTS.md](AGENTS.md) is the navigator — for Claude and for you.

## Lineage
The layout is [agent-atlas](https://github.com/zzallirog/agent-atlas) folded down to a
single machine; this kit is one working implementation of it.

---
🤝 **Handshake** — the kit's own rule, turned on itself: *trust the trace, not the
claim.* Don't take this README's word that your copy is whole. Clone it and run
`git rev-parse HEAD` — it must equal the commit hash GitHub shows at the top of this
page. A repo can't print its own commit hash inside itself, so the anchor lives
where you can't fake it: the commit, not the copy.
