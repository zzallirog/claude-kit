# THE PROTOCOL — who's in charge, who thinks, who presses

> What took one person 3 months. Read it — and you'll understand in 5 minutes.
> This isn't rules for the sake of rules. It's a division of responsibility between you and the AI
> that makes the work fast where it's safe, and careful where the cost of a
> mistake is high.

## The players

**🧑 OWNER — that's you.**
The laptop's owner. The highest authority. **You — and only you — have the password.**
The AI doesn't know it and doesn't type it. The kit's commands take root only through the ritual below;
to keep this holding even against a runaway agent — there's a guard hook (see
`conventions/security-root.md`). When the system asks for the password — that's not a
formality, it's the moment where **the human decides**. The password = your signature.

**🧠 ARCHITECT — Opus (admin).**
The thinking role. Plans, designs the defenses, holds the map: what lives where,
what fixes what, which step follows which. Advises and explains. This is "HQ".
When it's about configuring the system — work with the Architect (turn on `/model` Opus).

**⚙️ OPERATIVE — Sonnet.**
Fast and inexpensive — does the routine. It's let near root **more strictly**: each
risky step is a separate one-time grant, not "the keys to the apartment". About to go into
the system — it calls you first.

## Two spheres (this is the whole point)

```
┌─────────────────────────────┬─────────────────────────────────────┐
│  USERSPACE (your home ~/)    │  SYSTEM (root)                       │
│  free movement               │  under grant                        │
├─────────────────────────────┼─────────────────────────────────────┤
│  read / write files          │  updates, package installation       │
│  ~/projects, ~/kb, notes     │  firewall, close/open ports          │
│  diagnostics (look only)     │  restart system services             │
│  log search, laptop map      │  drivers, time, network, bootloader  │
│  → AI acts WITHOUT ceremony  │  → every time: GRANT (see below)     │
└─────────────────────────────┴─────────────────────────────────────┘
```

**The excess is removed:** in userspace the AI doesn't bother you over trifles (it's your home,
walk freely). In the system — the opposite, not a step without your "yes". There's no gray
middle: either it's clearly allowed, or you're clearly needed.

## The grant handshake (how temporary root is taken)

When the AI needs to go into the system, a short ritual plays out on screen:

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
  [the system asks for YOUR password]
  ✓ CONFIRMED — done. temporary root revoked. all clear.
```

Four beats, always in order:
1. **REQUEST** — the AI shows the exact command, the reason, and the risk. Nothing is
   hidden.
2. **GRANT** — you say yes/no. No → the action is not performed, period.
3. **PASSWORD** — the system asks for **your** password. The AI doesn't type it and doesn't see it.
4. **CONFIRMED → ALL CLEAR** — the command ran, temporary root **immediately
   revoked**. The AI is left with no "keys".

That's what "temporary root" means: the AI **borrows it for a single action**, doesn't
own it. The kit holds no permanent root for the assistant.

## The honest boundary (without this it would be a lie)

The ritual above is the **discipline of the kit's commands**: inside `update`/`fix` and so on
root goes only this way. But on its own it **does not forbid** the AI from calling `sudo`
around the kit — that's decided not by the kit, but by Claude Code's permissions on your machine.
So the real guarantee is two layers on top of the ritual:
1. your allowlist has no "allow any `sudo` without asking";
2. the **guard hook** cuts destructive actions from any AI command (not just the kit's).
Full rationale, for whom and why — `conventions/security-root.md`.

## Why this way (and not "give the AI root and let it work")

- A mistake in the system is expensive and sometimes irreversible. A human in the chain = a brake
  exactly where it's needed.
- The password is yours → every system change has a human author. If
  something went wrong — it's visible that it was decided, not that "it happened on its own".
- One thinks (the Architect), another does (the Operative), a third decides (you).
  No one combines "thought it up + did it + allowed it" in a single person — that's how
  proper security services are built.

## Toggles (for the curious)
- The drama can be turned off: `KIT_DRAMA=0` → dry mode without scenes.
- The AI's role in the scene: `KIT_ROLE=Architect` (Opus) / `Operative` (Sonnet).
- Full breakdown of the root policy — in `ROOT-POLICY.md`.

> Remember one thing: **the AI builds, advises, and executes. You decide. The key is
> yours.** Everything else is details of this.
