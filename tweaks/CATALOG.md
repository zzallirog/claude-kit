# Tweak catalog — adaptive, tailored to the user's hardware

This catalog is **not a script**. It's a menu for the `system-tune` skill. Claude
reads it, cross-checks it against the output of `probe-system.sh`, and proposes only
what fits THIS particular machine and this distribution. Every tweak comes with a
risk level and a rollback method.

## Risk traffic light
- 🟢 **green** — safe, easily reversible, can be applied with a plain "ok".
- 🟡 **yellow** — changes system behavior; needs an explicit "yes" + a rollback
  method.
- 🔴 **red** — power/temperature/drivers/bootloader; ONLY an explicit "yes", a backup
  is mandatory, explain the risk before running. On a beginner's borrowed/sole
  machine — propose cautiously and prefer not to touch it without need.

Always: the install command next to the rollback command. Audit first, then tweak.

---

## A. Basic hygiene (🟢)
- Update the system through its native package manager (determine it from probe):
  `pacman -Syu` / `apt update && apt upgrade` / `dnf upgrade` / `zypper dup`.
  Explain what this is and why it's done regularly.
- Enable TRIM for SSD/NVMe (if ROTA=0): `systemctl enable --now fstrim.timer`.
  Rollback: `systemctl disable --now fstrim.timer`.
- Install a basic set for studying (with consent): git, python3, pip/pipx.

## B. Desktop responsiveness (🟢/🟡)
- 🟢 zram (compressed swap in RAM) — helps with limited memory. On many
  distributions it installs as a package (`zram-generator` etc.). Rollback — remove
  the config/package.
- 🟡 `vm.swappiness` — on a desktop with ample RAM, a lower value (10–60) may feel
  more responsive; a trade-off of "responsiveness ↔ throughput". Test it live:
  `sysctl vm.swappiness=60` (temporarily). To make it permanent — a file in
  `/etc/sysctl.d/`. Rollback — remove the file. Don't pass it off as a "speedup"
  without a measurement.
- 🟡 CPU task scheduler / power profile (`tuned`, `power-profiles-daemon`): pick
  "performance"/"balanced" based on whether it's a laptop or a PC. Rollback —
  restore the previous profile.

## C. NVIDIA (🟡/🔴) — only if probe found NVIDIA
> This user's graphics card is **weaker** than the one on the reference machine, and
> a different model. Don't carry over any clock/power numbers; tune them for the
> specific card from `nvidia-smi`. Don't copy someone else's overclock.
- 🟡 Make sure the proprietary NVIDIA driver is installed (not nouveau), if the user
  needs 3D/video performance. Install it via the native package manager. This may
  require a reboot — warn about it.
- 🟡 On a laptop — check which GPU is active (often there's an integrated one +
  NVIDIA). Explain that for studying the integrated one is usually enough and it
  saves battery.
- 🔴 Any overclock / raising the power limit / custom clocks — by default do NOT
  propose to a beginner on a sole machine. If they ask for it themselves — explain
  the risk (heat, instability), do it in small steps, everything reversible
  (`nvidia-smi -rgc` resets the clocks), and only with explicit consent.

## D. Laptop power/temperature (🔴)
- Custom fan curves, undervolt, power limits — **the red zone**. For a beginner, by
  default do NOT touch. First make sure the system simply isn't overheating (you can
  view temperatures read-only). Change anything — only if there's a real problem and
  explicit consent, with a clear rollback.

## E. Bootloader / kernel (🔴)
- Boot parameters, switching the kernel, GRUB — high risk of "won't boot". Don't
  propose without an explicit request. If you do — first record the working
  configuration and the rollback method (a fallback menu entry / a snapshot).

---

## Rule for Claude
Before any 🟡/🔴: (1) show the exact command, (2) explain the effect and risk,
(3) give the rollback command, (4) wait for an explicit "yes". After applying —
check the result and say honestly whether it worked or not. Don't reproduce the
friend's reference machine by numbers — this hardware has its own limits.
