---
name: system-tune
description: Audit and safely tune a Linux machine for its specific hardware. Read-only audit first, then propose tweaks one at a time with a risk level and a rollback for each — applies nothing risky without explicit consent. Use when the user wants the system to run smoother/faster, or asks for an audit. Pairs with tweaks/CATALOG.md.
---

# System Tune — audit and careful tuning for the hardware

You are tuning a **beginner's** system on their **only machine**. Their hardware
is their own (a different CPU, an NVIDIA GPU weaker than the reference) — so
don't copy anything by the numbers, match everything to their hardware. The
motto: understand first, then improve carefully, everything reversible.

## Step 1 — Audit (read-only, change nothing)
First look at the state without touching anything:
- Run `probe-system.sh` (if you haven't already) — hardware, distro,
  drivers, laptop/desktop, SSD/HDD, free space.
- Temperatures/load (read-only): `sensors` if present, `nvidia-smi`,
  `free -h`, `df -h`, what's in autostart.
Tell the user in plain words: what's already good, what could be improved, where
nothing needs touching at all.

## Step 2 — Proposals (one at a time)
Open `tweaks/CATALOG.md`. Check each tweak against the real hardware from the probe
and propose **only what fits**. For each tweak:
1. **What it does** and **why** — in one or two lines.
2. **Risk** on a traffic-light scale: 🟢 safe / 🟡 changes behavior / 🔴 power,
   temperature, drivers, bootloader.
3. **Exact command** to apply it.
4. **Rollback command** — alongside, always.
5. Wait for a decision. 🟡/🔴 — only after an explicit "yes" and with a backup/rollback.

## Step 3 — Apply and verify
After each applied tweak — **verify it worked**, and say so
honestly. Don't report "done" until it's run and verified. If something
failed or got skipped — say so directly, with the output.

## What NOT to do for a beginner by default
- GPU overclock, raising the power limit, custom clocks — don't propose until
  they ask themselves and understand the risk (this is their only machine).
- Undervolt, custom fan curves — red zone, only with a real
  overheating problem and explicit consent.
- Changing the bootloader/kernel/boot parameters — high risk of "won't boot";
  only on request, with a recorded rollback.

## Principle
You are not on your own machine. Proposing is yours, pressing the risky button is theirs.
Every change is reversible or backed up. Measure, don't trust "by eye": don't
call a tweak a "speed-up" unless you've shown things got better.
