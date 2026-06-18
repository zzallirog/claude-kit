#!/usr/bin/env bash
# kb/known-issues.sh — registry of common Linux problems with detect+fix.
# Sourced by `fix`. This is the "base" that grows over time.
#
# HOW TO EXTEND (Claude does this from unfixed.jsonl):
#   1. Read ~/.local/state/kit-claude/unfixed.jsonl — what couldn't be fixed.
#   2. Find the root cause.
#   3. Add a new check_<name>() below + append its name to KIT_CHECKS.
# Each check_<name>():
#   - prints status, attempts a SAFE fix via run_root/run_user,
#   - returns 0 if OK or fixed, 1 if a real problem remains (→ logged).
# Honest scope: this is a growing set of COMMON issues, not "every bug ever".

# ---- order in which `fix` runs the checks --------------------------------
KIT_CHECKS=(
  check_disk_space
  check_time_sync
  check_dns
  check_wifi
  check_broken_packages
  check_failed_services
  check_orphans
)

# ---- disk space ----------------------------------------------------------
check_disk_space() {
  section "Disk"
  local usep; usep="$(df --output=pcent / 2>/dev/null | tail -1 | tr -dc '0-9')"
  [ -z "$usep" ] && { warn "couldn't read df"; return 0; }
  if [ "$usep" -ge 90 ]; then
    warn "root partition is ${usep}% full — this causes update and app failures"
    say "  large caches can be cleaned safely:"
    [ "$PM" = pacman ] && run_root "clear pacman cache (keep latest versions)" green paccache -rk2 2>/dev/null || true
    [ "$PM" = apt ]    && run_root "clear apt cache" green apt-get clean || true
    [ "$PM" = dnf ]    && run_root "clear dnf cache" green dnf clean all || true
    have journalctl && run_root "shrink system logs to 200M" green journalctl --vacuum-size=200M || true
    local after; after="$(df --output=pcent / 2>/dev/null | tail -1 | tr -dc '0-9')"
    [ "${after:-100}" -lt 90 ] && { ok "now ${after}%"; return 0; }
    log_unfixed "disk /" "cache/log cleanup" "still ${usep}% used"; return 1
  fi
  ok "enough space (${usep}% used)"; return 0
}

# ---- time sync (broken clock breaks TLS / updates) -----------------------
check_time_sync() {
  section "Clock / time sync"
  if have timedatectl; then
    if timedatectl show -p NTPSynchronized --value 2>/dev/null | grep -qi yes; then
      ok "time is synchronized"; return 0
    fi
    warn "time is NOT synchronized (breaks TLS and updates)"
    run_root "enable time synchronization" green timedatectl set-ntp true || true
    sleep 1
    timedatectl show -p NTPSynchronized --value 2>/dev/null | grep -qi yes && { ok "enabled"; return 0; }
    log_unfixed "NTP" "timedatectl set-ntp true" "did not synchronize"; return 1
  fi
  ok "timedatectl unavailable — skipping"; return 0
}

# ---- DNS -----------------------------------------------------------------
check_dns() {
  section "DNS (name resolution)"
  if getent hosts example.org >/dev/null 2>&1 || getent hosts cloudflare.com >/dev/null 2>&1; then
    ok "DNS works"; return 0
  fi
  # names don't resolve — is there any network at all?
  if ping -c1 -W2 1.1.1.1 >/dev/null 2>&1; then
    warn "network is up, but names don't resolve → the problem is specifically DNS"
    if have resolvectl; then
      run_root "restart the system DNS resolver" yellow systemctl restart systemd-resolved || true
    fi
    have nmcli && run_root "reload the network (NetworkManager)" yellow nmcli general reload || true
    sleep 1
    getent hosts example.org >/dev/null 2>&1 && { ok "DNS started"; return 0; }
    warn "if that didn't help — you can temporarily set a public DNS (1.1.1.1 / 8.8.8.8);"
    warn "  this edits /etc/resolv.conf — let Claude help, so as not to break the network config"
    log_unfixed "DNS" "restart systemd-resolved + nmcli reload" "names still don't resolve"; return 1
  fi
  warn "no connectivity at all — this isn't DNS, it's the network/Wi-Fi (see the next step)"; return 0
}

# ---- Wi-Fi / network -----------------------------------------------------
check_wifi() {
  section "Network / Wi-Fi"
  if ping -c1 -W2 1.1.1.1 >/dev/null 2>&1; then ok "connection is up"; return 0; fi
  warn "no connection"
  # rfkill: radio blocked?
  if have rfkill && rfkill list 2>/dev/null | grep -qi 'Soft blocked: yes'; then
    warn "wireless module is software-blocked"
    run_root "unblock the radio (rfkill)" green rfkill unblock all || true
  fi
  if have nmcli; then
    nmcli radio wifi on >/dev/null 2>&1 || true
    run_root "restart NetworkManager" yellow systemctl restart NetworkManager || true
    sleep 2
    ping -c1 -W2 1.1.1.1 >/dev/null 2>&1 && { ok "network came up"; return 0; }
    say "  available networks:"; nmcli -t -f SSID,SIGNAL device wifi list 2>/dev/null | head -8 | sed 's/^/    /'
    warn "connect to your network: nmcli device wifi connect \"NETWORK_NAME\" password \"PASSWORD\""
  fi
  ping -c1 -W2 1.1.1.1 >/dev/null 2>&1 && { ok "ok"; return 0; }
  log_unfixed "network/Wi-Fi" "rfkill unblock + restart NetworkManager" "still no connection"; return 1
}

# ---- broken / inconsistent packages -------------------------------------
check_broken_packages() {
  section "Package integrity"
  case "$PM" in
    pacman)
      if run_user "check the package databases" pacman -Dk 2>&1 | grep -qi 'missing\|error'; then
        warn "dependency inconsistencies found"
        log_unfixed "pacman -Dk" "check" "missing/error present — needs a manual review with Claude"; return 1
      fi ;;
    apt)
      if ! sudo apt-get -f install --dry-run >/dev/null 2>&1; then
        warn "apt reports broken dependencies"
        run_root "fix broken apt dependencies" yellow apt-get -f install || { log_unfixed "apt deps" "apt-get -f install" "did not get fixed"; return 1; }
      fi ;;
    dnf) run_user "dnf check" dnf check >/dev/null 2>&1 || warn "dnf check reported problems — review with Claude" ;;
    *) say "  package manager not recognized — skipping" ; return 0 ;;
  esac
  ok "packages are intact"; return 0
}

# ---- failed systemd services --------------------------------------------
check_failed_services() {
  section "Services (systemd)"
  have systemctl || { ok "not systemd — skipping"; return 0; }
  local failed; failed="$(systemctl --failed --no-legend --plain 2>/dev/null | awk '{print $1}')"
  if [ -z "$failed" ]; then ok "no failed services"; return 0; fi
  warn "failed services:"; printf '%s\n' "$failed" | sed 's/^/    /'
  say "  see the cause: systemctl status <name> / journalctl -u <name> -b"
  log_unfixed "failed services" "detection" "$failed"; return 1
}

# ---- orphaned packages (offer cleanup, never forced) ---------------------
check_orphans() {
  section "Orphaned packages (optional cleanup)"
  case "$PM" in
    pacman)
      local orph; orph="$(pacman -Qdtq 2>/dev/null)"
      [ -z "$orph" ] && { ok "no orphans"; return 0; }
      warn "orphans (no longer needed by anyone):"; printf '%s\n' "$orph" | sed 's/^/    /'
      if confirm "Remove orphans?" yellow; then
        # shellcheck disable=SC2086
        run_root "remove orphaned packages" yellow pacman -Rns $orph || true
      fi ;;
    apt) run_root "remove unneeded packages (autoremove)" green apt-get -y autoremove || true ;;
    dnf) run_root "remove unneeded packages (autoremove)" green dnf -y autoremove || true ;;
    *) ok "skipping" ;;
  esac
  return 0
}
