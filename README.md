# claude-kit

> A ready-to-run **Claude Code starter kit** — roles & safety, skills, commands, and a
> clean filesystem/memory layout. What took one person three months, packaged so a
> newcomer gets going in five minutes.

Built for a specific beginner (a psychology student on Linux); the shape is general —
the persona is just the worked example. The whole thesis fits in one picture — where the
AI walks freely, and where it has to stop and ask you:

```
┌─────────────────────────────┬─────────────────────────────────────┐
│  USERSPACE (your home ~/)    │  SYSTEM (root)                       │
│  free movement               │  under grant                        │
├─────────────────────────────┼─────────────────────────────────────┤
│  read / write files          │  updates, package installation      │
│  ~/projects, ~/kb, notes     │  firewall, close/open ports         │
│  diagnostics (look only)     │  restart system services            │
│  log search, laptop map      │  drivers, time, network, bootloader │
│  → AI acts WITHOUT ceremony  │  → every time: GRANT + your password│
└─────────────────────────────┴─────────────────────────────────────┘
```

No gray middle: either it's clearly your home and the AI just works, or it's the system
and you're clearly needed. That line is the kit.

## Quick start

```bash
git clone https://github.com/zzallirog/claude-kit && cd claude-kit
claude
```

Then tell Claude one phrase:

> read BOOTSTRAP.md and begin

Claude runs the onboarding itself: probes your machine, asks a short intake, offers
skills **one at a time** (installs nothing without your "yes"), sets up commands, and
lays down a clean layout. Beginner-facing walkthrough for the human: **[START-HERE.md](START-HERE.md)**.

## What you get

- **Skills** — `stats-lab` · `data-wrangle` · `research-helper` · `linux-tutor` · `system-tune` · `man`. Copied into `~/.claude/skills/` only on consent.
- **Commands** — `update` (system update + security check in one) · `fix` (self-healing: disk/DNS/Wi-Fi/packages, grows its own known-issues registry) · `where` (map of the laptop) · `recall` (search notes + logs) · `kit-help` (cheatsheet) · `kit-guide` (a browser dossier, <kbd>Super</kbd>+<kbd>\\</kbd>).
- **Safety by construction** — root is never standing: every system action passes a four-beat **grant ritual** (request → your yes → *your* password → auto-revoke). A guard hook (`hooks/deny-destructive.sh`) cuts destructive commands from *any* AI action, not just the kit's.
- **A clean layout** — a typed filesystem + memory kept [clean for Claude](conventions/layout.md): a map, not a dump — load only what's needed. The concept is [agent-atlas](https://github.com/zzallirog/agent-atlas) folded down to a single machine.

## The protocol (who's in charge)

**You decide · Opus thinks · Sonnet does — and the key is yours.** Home (`~/`) is free;
the system (root) moves only through a one-time grant that *you* confirm with your
password. The AI doesn't know it and doesn't type it.

<details>
<summary><b>The grant handshake</b> — how temporary root is taken (4 beats)</summary>

```
┌─ GRANT REQUEST ─ root ────────────────────────────
│ requested by : AI operative
│ operation    : close unneeded port 5355
│ command      : sudo ufw deny 5355
│ risk         : 🟡 medium
│ authorized ONLY by the owner — without your password the ritual won't pass.
└───────────────────────────────────────────────────
  Owner, grant access? [y/N]: y
  ● grant issued. handing to the system — enter the password (this is the confirmation):
  ✓ CONFIRMED — done. temporary root revoked. all clear.
```

1. **REQUEST** — the AI shows the exact command, the reason, the risk. Nothing hidden.
2. **GRANT** — you say yes/no. No → not performed, period.
3. **PASSWORD** — the system asks for *your* password. The AI never sees or types it.
4. **CONFIRMED → ALL CLEAR** — the command ran, temporary root immediately revoked.

Full model: **[THE-PROTOCOL.md](THE-PROTOCOL.md)**.
</details>

<details>
<summary><b>The honest boundary</b> — what the kit does and doesn't guarantee</summary>

The ritual is the discipline of the *kit's own commands*: inside `update`/`fix` root goes
only that way (the single path is `run_root()` in `bin/kit-lib.sh`). But the kit **cannot
by itself forbid** the AI from calling `sudo` around it — that's Claude Code's permissions,
not the kit's. So the real guarantee is two layers on top of the ritual:

1. your allowlist has no "allow any `sudo` without asking" (`config/claude-allowlist.json`);
2. the **guard hook** cuts destructive actions from *any* AI command.

Full rationale: **[ROOT-POLICY.md](ROOT-POLICY.md)** · **[conventions/security-root.md](conventions/security-root.md)**.
</details>

## Map

**[AGENTS.md](AGENTS.md)** is the navigator — a route into the kit for both Claude and you,
so nobody has to read the whole thing to find one door.

<details>
<summary><b>Repo layout</b></summary>

```
BOOTSTRAP.md      the onboarding script Claude runs
START-HERE.md     the entry point for the human
THE-PROTOCOL.md   roles (owner / architect / operative) + temporary root
ROOT-POLICY.md    the full root policy
CONVENTIONS.md    working habits (fish · projects · kb · where/recall)
conventions/      layout.md (clean-for-Claude) · security-root.md
skills/           stats-lab · data-wrangle · research-helper · linux-tutor · system-tune · man
bin/              kit-install · update · fix · where · recall · kit-guide · kit-keybind
hooks/            deny-destructive.sh (guard hook)
kb/               known-issues.sh (self-healing fix) · README.md
tweaks/           CATALOG.md (system tweaks)
config/           claude-allowlist · fastfetch · layout.example
guide/            kit-guide.html (the dossier, Super+\)
```
</details>

## Honest scope

- **Linux, one machine.** Built and exercised on a single beginner's Linux laptop; the
  layout is [agent-atlas](https://github.com/zzallirog/agent-atlas) collapsed to one host.
  macOS/Windows and multi-machine setups are out of scope for now.
- **One worked persona.** Tested against the shape it was built for (a psychology student).
  The structure generalizes; the intake questions and skill picks are that example.
- **Designed for Opus.** It runs on Sonnet — a bit more simply — and Claude says so at
  start if Opus isn't on.
- **No CI yet.** The guard hook and the grant path are the load-bearing safety; they're
  reasoned in the docs, not gated by an automated suite.

## Lineage

The layout is [agent-atlas](https://github.com/zzallirog/agent-atlas) folded down to a
single machine; this kit is one working implementation of it.

## Changelog

Version history in **[CHANGELOG.md](CHANGELOG.md)**.

---

🤝 **Handshake** — the kit's own rule, turned on itself: *trust the trace, not the claim.*
Don't take this README's word that your copy is whole. Clone it and run
`git rev-parse HEAD` — it must equal the commit hash GitHub shows at the top of this page.
A repo can't print its own commit hash inside itself, so the anchor lives where you can't
fake it: the commit, not the copy.

## License

MIT.
