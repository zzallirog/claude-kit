#!/usr/bin/env bash
# deny-destructive.sh — PreToolUse hook (matcher: Bash).
# Sees the AI agent's COMMANDS before they run and cuts destructive ones via PCRE regex.
# Intercepts only the assistant's tool-calls, NOT the user's manual terminal input,
# so the hands-on homelab flow isn't affected — the strictness applies to the AI only.
#
# Contract (verified): reads JSON from stdin (.tool_input.command); on a match it
# prints permissionDecision:deny and exits 0. Otherwise — silently exits 0 (normal flow).
#
# Test: echo '{"tool_input":{"command":"rm -rf /"}}' | deny-destructive.sh
set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -z "$cmd" ] && exit 0

# --- PCRE destructive filters (label|regex). grep -Pi, backref support. ---
# System roots (for rm/chmod/chown). /home,/root,/var are NOT included on purpose —
# deep edits under them are legitimate; we only cut the whole root and the system.
SYS='/|/\*|/etc|/usr|/bin|/sbin|/boot|/lib|/lib64|/sys|/proc|/dev|/root'

# Format: "label@@regex" (@@ — separator; it appears in neither labels nor regexes).
patterns=(
  "classic fork bomb@@:\s*\(\s*\)\s*\{.*:\s*\|\s*:.*&.*\}\s*;\s*:"
  "named fork bomb (self-recursion)@@([a-z_]\w*)\s*\(\s*\)\s*\{[^}]*\|[^}]*&[^}]*\}\s*;\s*\1"
  "rm -r over root/system/home@@\brm\b(?=.*(?:\s-\w*[rR]|\s--recursive)).*(?:\s|=)(?:/|/\*|~|\\\$HOME|/etc|/usr|/bin|/sbin|/boot|/lib|/lib64|/sys|/proc|/dev|/root)(?:\s|/|\*|\"|'|\$)"
  "removing root protection --no-preserve-root@@--no-preserve-root"
  "mkfs on a device@@\bmkfs(\.\w+)?\b[^|;&]*\s/dev/"
  "dd writing to a block device@@\bdd\b[^|;&]*\bof\s*=\s*/dev/(sd|nvme|vd|mmcblk|hd|disk|loop)"
  "redirect to a device@@>\s*/dev/(sd|nvme|vd|mmcblk|hd)"
  "wiping a partition wipefs/blkdiscard/shred@@\b(wipefs|blkdiscard|shred)\b[^|;&]*\s/dev/"
  "download-and-run from the network into a shell@@\b(curl|wget|fetch)\b[^|]*\|\s*(sudo\s+)?(ba|z|k|d)?sh\b"
  "chmod 777 over root/system@@\bchmod\b[^|;&]*\s0*777\s+/(\s|\$|\*|etc|usr|bin|sbin|boot|lib|sys|dev|\")"
  "chown -R over the system@@\bchown\b[^|;&]*\s(-R|--recursive)\b[^|;&]*\s/(\s|\$|etc|usr|bin|sbin|boot|lib|sys|dev|\")"
)

for entry in "${patterns[@]}"; do
  label="${entry%%@@*}"; rx="${entry#*@@}"
  if printf '%s' "$cmd" | grep -Piq -- "$rx"; then
    jq -nc --arg r "Blocked by the guard hook: $label. The command was not run. If the action is intentional, run it manually in your own terminal (the hook gates the AI only)." \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    exit 0
  fi
done
exit 0
