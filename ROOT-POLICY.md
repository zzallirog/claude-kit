# ROOT-POLICY — how the kit handles root privileges (security)

Principle: **root is tied to security.** This is a beginner's machine — the cost of a mistake is
high, so root is not "spilled" across the kit's scripts (see the honest boundary below:
the kit itself doesn't forbid the AI from calling `sudo` around it — that's held by the allowlist + guard hook,
`conventions/security-root.md`).

## What the scripts guarantee
1. **No script runs entirely as root.** Run them as an ordinary
   user. Root is requested pointwise, for a specific operation.
2. **The only path to root is the `run_root()` function** (in `bin/kit-lib.sh`).
   Before every `sudo` it:
   - prints the **exact command** and the **reason** to the human;
   - runs the command through a light denylist (`guard_dangerous`): `rm -rf /`,
     `mkfs`, `dd … of=/dev/…`, fork bomb, `chmod -R 777 /`, `--no-preserve-root`.
     This is a **safety net inside the kit's commands** (a substring check). A full,
     regex shield over ALL the AI's commands — a separate guard hook (see below);
   - asks for confirmation. In autonomous mode (`--auto`) an auto-"yes"
     is given **only to green** operations; yellow/red **still ask**.
3. **`--dry-run`** shows everything that would be done, executing nothing.
4. **Everything is logged** to `~/.local/state/kit-claude/kit.log`.

## The traffic light (as in tweaks/CATALOG.md)
- 🟢 safe/reversible — an auto-yes is possible in `--auto`.
- 🟡 changes behavior — an explicit "yes" needed.
- 🔴 power/temperature/drivers/bootloader — an explicit "yes" + a backup; by default
  the kit should **not offer these to a beginner without a request**.

## Claude Code allowlist
`config/claude-allowlist.json` allows Claude **only harmless read-only**
commands without asking (statuses, reads, diagnostics). `sudo *` stays in `ask`,
and destructive patterns — in `deny`. That is, "the allowlists are open" for convenience,
but **root and the dangerous stuff are still behind the gate**.

## The guard hook (regex shield over all AI commands)
`hooks/deny-destructive.sh` — a Claude Code PreToolUse hook. It sees **every**
Bash command from the AI before it runs and cuts destructive ones by regex (fork bombs, `rm -r` over the
system, `dd`/`mkfs`/`wipefs` over devices, `curl|sh`, `chmod 777 /` and so on).
Important: it gates **only the AI agent, not you in the terminal**. `kit-install` installs and
registers it. Why exactly this way — `conventions/security-root.md`.

## What this does NOT do
It doesn't disable the sudo password, doesn't grant passwordless root, doesn't edit `/etc/sudoers`,
doesn't open network ports. And the kit itself **does not control** Claude
Code's permissions: if your allowlist has "any `sudo` without asking", the `run_root` ritual
is bypassed — then the only barrier to destructive actions remains the guard hook. That's why it's
not cosmetics, but a load-bearing layer.
