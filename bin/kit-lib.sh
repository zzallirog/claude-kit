#!/usr/bin/env bash
# kit-lib.sh — shared safety + helpers for the kit-claude scripts.
# Sourced by `update`, `fix`, `kit-install`, `kit-help`. Not run directly.
#
# Design rule: ROOT IS TIED TO SAFETY.
#  - No script ever runs wholesale as root.
#  - Every privileged action goes through run_root(), which: prints the EXACT
#    command + reason, screens it against a hard denylist, and (unless the user
#    opted into --yes/--auto) asks for confirmation before `sudo`.

# ---- state / paths -------------------------------------------------------
KIT_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/kit-claude"
KIT_LOG="$KIT_STATE_DIR/kit.log"
KIT_UNFIXED="$KIT_STATE_DIR/unfixed.jsonl"
mkdir -p "$KIT_STATE_DIR" 2>/dev/null || true

# ---- flags (set by callers, read by helpers) -----------------------------
: "${KIT_AUTO:=0}"   # 1 = non-interactive; auto-yes for GREEN actions only
: "${KIT_YES:=0}"    # 1 = auto-yes for ALL actions (use with care)
: "${KIT_DRYRUN:=0}" # 1 = print, never execute privileged actions

# ---- color (degrade gracefully if no tty) --------------------------------
if [ -t 1 ]; then
  C_R='\033[31m'; C_G='\033[32m'; C_Y='\033[33m'; C_B='\033[36m'; C_0='\033[0m'; C_BOLD='\033[1m'
else
  C_R=''; C_G=''; C_Y=''; C_B=''; C_0=''; C_BOLD=''
fi
say()  { printf '%b\n' "$*"; }
ok()   { printf '%b\n' "${C_G}✓${C_0} $*"; }
warn() { printf '%b\n' "${C_Y}!${C_0} $*"; }
err()  { printf '%b\n' "${C_R}✗${C_0} $*" >&2; }
section() { printf '\n%b\n' "${C_BOLD}${C_B}== $* ==${C_0}"; }
logln(){ printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$KIT_LOG" 2>/dev/null || true; }

# ---- confirmation --------------------------------------------------------
# confirm "question" [risk]   risk = green|yellow|red  (default green)
confirm() {
  local q="$1" risk="${2:-green}"
  [ "$KIT_YES" = "1" ] && return 0
  if [ "$KIT_AUTO" = "1" ] && [ "$risk" = "green" ]; then return 0; fi
  # yellow/red ALWAYS ask, even in --auto.
  if [ ! -r /dev/tty ]; then warn "no terminal to confirm \"$q\" — skipping (safe)"; return 1; fi
  local ans
  printf '%b ' "${C_Y}?${C_0} $q [y/N]:"
  read -r ans </dev/tty 2>/dev/null || ans=""
  case "$ans" in [yY]|yes) return 0;; *) return 1;; esac
}

# ---- hard denylist: refuse obviously destructive commands ----------------
guard_dangerous() {
  local joined="$*"
  case "$joined" in
    *"rm -rf /"*|*"rm -fr /"*|*":(){"*|*"mkfs"*|*"dd if="*"of=/dev/"*|\
    *"> /dev/sd"*|*"chmod -R 777 /"*|*"chown -R"*" /"|*"--no-preserve-root"*)
      err "BLOCKED — refusing dangerous command: $joined"
      logln "BLOCKED dangerous: $joined"
      return 1;;
  esac
  return 0
}

# ---- security drama: roles + grant handshake (see THE-PROTOCOL.md) --------
: "${KIT_DRAMA:=1}"        # 1 = detective mode (default); 0 = plain
: "${KIT_ROLE:=Operative}" # the AI's role in the scene: Architect (Opus) / Operative (Sonnet)
risk_label() { case "$1" in green) echo "🟢 low";; yellow) echo "🟡 medium";; red) echo "🔴 HIGH";; *) echo "$1";; esac; }
_drama() { [ "$KIT_DRAMA" = "1" ] && [ -t 1 ]; }

# ---- the only path to root ----------------------------------------------
# run_root "human reason" risk cmd...
run_root() {
  local reason="$1" risk="$2"; shift 2
  guard_dangerous "$@" || return 1
  if _drama; then
    printf '%b\n' "${C_BOLD}${C_Y}┌─ GRANT REQUEST ─ root ────────────────────────────${C_0}"
    printf '%b\n' "${C_Y}│${C_0} requested by : AI-${KIT_ROLE}"
    printf '%b\n' "${C_Y}│${C_0} operation    : $reason"
    printf '%b\n' "${C_Y}│${C_0} command      : ${C_BOLD}sudo $*${C_0}"
    printf '%b\n' "${C_Y}│${C_0} risk         : $(risk_label "$risk")"
    printf '%b\n' "${C_Y}│ ONLY the owner authorizes. The AI cannot log in by itself.${C_0}"
    printf '%b\n' "${C_BOLD}${C_Y}└───────────────────────────────────────────────────${C_0}"
  else
    say "${C_B}→ root needed:${C_0} $reason  [risk: $(risk_label "$risk")]"
    say "  ${C_BOLD}sudo $*${C_0}"
  fi
  if [ "$KIT_DRYRUN" = "1" ]; then warn "(dry-run, not executing)"; return 0; fi
  if ! confirm "Owner, issue the grant?" "$risk"; then
    _drama && err "DENIED by the owner — action not performed." || warn "skipped by user"
    logln "SKIP root: $*"; return 2
  fi
  _drama && say "${C_G}● grant issued.${C_0} handing off to the system — enter your password (that is the confirmation):"
  logln "ROOT: $*"
  if sudo "$@"; then
    _drama && say "${C_G}✓ CONFIRMED${C_0} — done. temporary root revoked. ${C_B}over and out.${C_0}"
    return 0
  else
    err "command returned an error — temporary root revoked, nothing left open"
    logln "ROOT-FAIL: $*"; return 1
  fi
}

# run as user, but visible + logged (no root)
run_user() {
  local reason="$1"; shift
  guard_dangerous "$@" || return 1
  say "  ${C_BOLD}$*${C_0}  ${C_B}# $reason${C_0}"
  [ "$KIT_DRYRUN" = "1" ] && { warn "(dry-run)"; return 0; }
  logln "USER: $*"
  "$@"
}

have() { command -v "$1" >/dev/null 2>&1; }

# ---- distro detection: sets PM and PM_* command strings ------------------
detect_distro() {
  DISTRO_ID="unknown"; DISTRO_NAME="unknown"
  if [ -r /etc/os-release ]; then . /etc/os-release; DISTRO_ID="${ID:-unknown}"; DISTRO_NAME="${PRETTY_NAME:-$ID}"; fi
  PM=""; PM_SYNC=""; PM_UPGRADE=""; PM_INSTALL=""; PM_CHECK=""; PM_AUTOREMOVE=""
  if   have pacman; then PM=pacman;  PM_SYNC="pacman -Sy";              PM_UPGRADE="pacman -Syu --noconfirm"; PM_INSTALL="pacman -S --needed --noconfirm"; PM_CHECK="pacman -Dk";       PM_AUTOREMOVE="pacman -Rns \$(pacman -Qdtq)"
  elif have apt;    then PM=apt;     PM_SYNC="apt-get update";          PM_UPGRADE="apt-get -y full-upgrade"; PM_INSTALL="apt-get -y install";            PM_CHECK="apt-get -f install --dry-run"; PM_AUTOREMOVE="apt-get -y autoremove"
  elif have dnf;    then PM=dnf;     PM_SYNC="dnf makecache";           PM_UPGRADE="dnf -y upgrade";          PM_INSTALL="dnf -y install";                PM_CHECK="dnf check";        PM_AUTOREMOVE="dnf -y autoremove"
  elif have zypper; then PM=zypper;  PM_SYNC="zypper refresh";          PM_UPGRADE="zypper -n dup";           PM_INSTALL="zypper -n install";             PM_CHECK="zypper verify --dry-run"; PM_AUTOREMOVE="zypper -n packages --orphaned"
  fi
  export DISTRO_ID DISTRO_NAME PM PM_SYNC PM_UPGRADE PM_INSTALL PM_CHECK PM_AUTOREMOVE
}

# ---- learning log: record what could NOT be fixed ------------------------
# log_unfixed "problem" "what was tried" "extra detail"
log_unfixed() {
  local problem="$1" tried="$2" detail="${3:-}"
  local ts; ts="$(date '+%Y-%m-%dT%H:%M:%S')"
  # minimal JSONL, escaped for quotes/backslashes
  esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
  printf '{"ts":"%s","problem":"%s","tried":"%s","detail":"%s","root_cause":"TODO — ask Claude to analyze","status":"unfixed"}\n' \
    "$ts" "$(esc "$problem")" "$(esc "$tried")" "$(esc "$detail")" >>"$KIT_UNFIXED" 2>/dev/null || true
  warn "couldn't fix it → recorded in $KIT_UNFIXED"
  warn "  ask Claude: \"go through unfixed.jsonl, find the root cause, add it to kb/known-issues.sh\""
}
