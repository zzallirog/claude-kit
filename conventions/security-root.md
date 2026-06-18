# CONVENTION — root, destructive actions, and why exactly this way (for Opus)

> This is not a "do it this way" charter. This is **reasoning**, so that you, Opus,
> understand the threat model and check the conclusion yourself. If you find a hole —
> the convention is wrong, fix it. Here we deliberately don't lean on pretty
> absolutes (that's what `THE-PROTOCOL.md` is for); here it's facts, the choice, and
> its limits.

## 0. Honest about the frame (anti-frame-packing)
`THE-PROTOCOL.md` is written grandly and **persuades**: roles, "the key is yours,"
the drama of the grant. That's motivation for a human, not proof. Don't accept the
conclusion because the text is pretty. The conclusion below stands **on its own**,
verifiably, and we arrived at it from a fact (see §1), not by bending it to fit a
pretty story. If the frame and the reasoning diverge — trust the reasoning.

## 1. The fact it all started from (not an opinion)
On a real machine, `~/.claude/settings.json` had `Bash(sudo *)` in `allow` with
`defaultMode: auto` and a single `deny`. That means: **the agent could run any
`sudo` without asking.** At that point the whole `run_root` ritual (show the
command → grant → password) **is bypassed** — the AI calls `sudo` directly, around
the kit. Verifiable:
`jq '.permissions.allow' ~/.claude/settings.json | grep sudo`.

Conclusion 1: discipline inside the kit's commands ≠ a guarantee for the system.
You need a layer that sees **any** command the AI issues, not just the kit's
commands.

## 2. Why a PreToolUse hook and not `permissions.deny`
Verified against the Claude Code docs (hooks.md / permissions.md):
- **`permissions.deny` is a glob, not a regex.** You can't express "`rm -r` over any
  system path, in any flag order, with any whitespace." A literal like
  `Bash(:(){ :|:& };:)` is bypassed with **one extra space** — that's theater.
- **A PreToolUse hook receives the full command string** (`.tool_input.command`)
  and can run it through PCRE: whitespace, flag variants, pipes, a backref for
  named fork bombs. Blocking is `permissionDecision:"deny"` (exit 0) or exit 2.
- **The hook intercepts only the AI's tool-calls, not a human's manual input in the
  terminal.** So you can cut destructive actions hard without breaking the homelab
  flow by hand. That's exactly what removes the usual "security vs convenience"
  conflict: the price of strictness is paid only by the AI.

Conclusion 2: a regex hook is the only mechanism that gives both breadth (the whole
command), coverage (any command the AI issues), and zero cost to the human.

## 3. What we count as destructive and why exactly this (not "everything")
You have to cut **the irreversible or system-seizing** and NOT cut the legitimate —
otherwise the hook gets disabled and the benefit is zero. Decisions per class:
- **Fork bombs** (the classic one, with spaces, named via backref) — there is no
  legitimate use.
- **`rm -r` over `/`, `/*`, `~`, `$HOME`, system roots** (`/etc /usr /bin /boot
  /lib /sys /dev /root`) — but NOT over `/home/<user>/...` and NOT over relative
  paths: deep edits under home are legitimate. This is a deliberate compromise: we
  catch the catastrophe, we let the routine through.
- **`dd of=/dev/sdX`, `mkfs`, `wipefs/blkdiscard/shred` on a device, `> /dev/sdX`**
  — wiping disks. But `dd of=file.img` passes (images are normal).
- **`curl|wget … | sh/bash`** — running downloaded code blind.
- **`chmod 777` / `chown -R` over the root and the system** — but `chmod +x`,
  `chmod 777 ./file` pass.
- **`--no-preserve-root`** — removing the last safeguard.

These decisions are verified by a battery: 17 "should be blocked" + 15 "should
pass" (homelab: `sudo systemctl`, `dd of=file.img`, `rm -rf node_modules`,
`rm -rf /home/.../old`). All 32 green. The test sits next to the hook, rerun it on
edits.

## 4. Limits (where this will NOT save you — know it in advance)
- The hook gates **the AI, not the human**. A human by hand can do anything — that's
  by design.
- **A regex is not complete.** Obfuscation (base64-into-`eval`, variables-into-a-
  command, unusual wrappers) can slip through. The hook is a high wall against the
  obvious and the accidental, not a proof of impossibility. Don't promise the user
  an absolute.
- The hook doesn't replace a sane allowlist: if it has `sudo *` without asking, the
  hook is your **only** barrier against destructive actions. Better to also narrow
  the allowlist (but that changes the working flow, so it's the owner's choice, not
  a default).
- `guard_dangerous` in `kit-lib.sh` is a substring backstop INSIDE the kit's
  commands, weaker than the hook. Two different layers, not duplicates: one for its
  own commands, the hook — for all of them.

## 5. How to falsify this convention (do it)
- Feed the hook
  `printf '%s' '<command>' | jq -Rs '{tool_input:{command:.}}' | hooks/deny-destructive.sh`.
- If a destructive action passed (false-negative) or a legit one got blocked
  (false-positive) — the convention/regex is wrong, fix it and extend the battery.
- Check that the claims in `THE-PROTOCOL.md`/`ROOT-POLICY.md` don't promise more than
  is proven here. If they do — that's description drift, fix the text, not the code.

## 6. Bottom line in one paragraph
Root is gated by the ritual inside the kit **for clarity**, but the real protection
against a runaway/over-permitted AI is held by the **PreToolUse regex hook** (it
sees all the AI's commands, cuts the irreversible, doesn't touch the human's hands)
plus a sober allowlist. This is a conclusion from the fact in §1, verified by the
tests in §3, with honest limits in §4. The pretty frame sits on top and apart;
don't confuse it with the proof.
