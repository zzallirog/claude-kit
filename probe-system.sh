#!/usr/bin/env bash
# probe-system.sh — read-only system probe. No sudo, no changes.
# Safe to run anywhere. Output is meant to be read by Claude + the user.

set -u
line() { printf '%s\n' "------------------------------------------------------------"; }
have() { command -v "$1" >/dev/null 2>&1; }

echo "===== SYSTEM PROBE ($(date '+%Y-%m-%d %H:%M')) ====="

line; echo "[OS / DISTRO]"
if [ -r /etc/os-release ]; then
  . /etc/os-release
  echo "Name      : ${PRETTY_NAME:-unknown}"
  echo "ID        : ${ID:-unknown}   ID_LIKE: ${ID_LIKE:-}"
fi
echo "Kernel    : $(uname -r)"
echo "Arch      : $(uname -m)"

line; echo "[PACKAGE MANAGER]"
for pm in pacman apt dnf zypper xbps-install emerge; do
  have "$pm" && echo "Detected  : $pm"
done

line; echo "[CPU]"
if have lscpu; then
  lscpu | grep -E 'Model name|^CPU\(s\)|Thread|Core|MHz|Vendor ID' | sed 's/^/  /'
else
  grep -m1 'model name' /proc/cpuinfo | sed 's/^/  /'
  echo "  Cores   : $(nproc 2>/dev/null)"
fi

line; echo "[MEMORY]"
if have free; then free -h | sed 's/^/  /'; fi

line; echo "[GPU]"
if have lspci; then
  lspci | grep -Ei 'vga|3d|display' | sed 's/^/  /'
fi
if have nvidia-smi; then
  echo "  -- NVIDIA --"
  nvidia-smi --query-gpu=name,driver_version,memory.total,power.limit --format=csv,noheader 2>/dev/null | sed 's/^/  /'
else
  echo "  (nvidia-smi not found — NVIDIA driver may be absent or open-source nouveau)"
fi
echo "  Loaded GPU kernel modules:"
lsmod 2>/dev/null | grep -Ei 'nvidia|nouveau|amdgpu|i915|radeon' | awk '{print "    "$1}' | sort -u

line; echo "[LAPTOP / DESKTOP]"
if [ -d /sys/class/power_supply ] && ls /sys/class/power_supply/ 2>/dev/null | grep -qi bat; then
  echo "  Likely a LAPTOP (battery present)"
else
  echo "  Likely a DESKTOP (no battery detected)"
fi

line; echo "[DESKTOP / DISPLAY]"
echo "  Session   : ${XDG_SESSION_TYPE:-unknown} (wayland/x11)"
echo "  Desktop   : ${XDG_CURRENT_DESKTOP:-unknown}"
echo "  Shell     : ${SHELL:-unknown}"

line; echo "[STORAGE]"
if have lsblk; then
  lsblk -d -o NAME,SIZE,ROTA,MODEL 2>/dev/null | sed 's/^/  /'
  echo "  (ROTA=1 means spinning HDD, ROTA=0 means SSD/NVMe)"
fi
echo "  Free space on /:"
df -h / 2>/dev/null | sed 's/^/  /'

line; echo "[USEFUL TOOLS PRESENT]"
for t in git python3 R Rscript pip pipx conda jupyter docker flatpak code; do
  have "$t" && echo "  yes: $t"
done

line; echo "[CLAUDE SKILLS ALREADY INSTALLED]"
if [ -d "$HOME/.claude/skills" ]; then
  ls -1 "$HOME/.claude/skills" 2>/dev/null | sed 's/^/  /' || echo "  (none)"
else
  echo "  ~/.claude/skills does not exist yet"
fi

line; echo "===== END PROBE ====="
