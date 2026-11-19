# Gemeinsame Funktionen für die Hard Gaming Konsole (wird per "source" geladen).
KONSOLE_GPU=auto
KONSOLE_FENSTER_BREITE=1280
KONSOLE_FENSTER_HOEHE=720
KONSOLE_GAMESCOPE_EXTRA=""
KONSOLE_DESKTOP_FALLBACK=1
KONSOLE_FENSTER_GAMESCOPE=0
KONSOLE_HYBRID_SITZUNG=0
KONSOLE_WAECHTER_SEKUNDEN=25
[[ -r /etc/hard-gaming-os/konsole.conf ]] && . /etc/hard-gaming-os/konsole.conf
[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/hard-gaming-konsole.conf" ]] && . "${XDG_CONFIG_HOME:-$HOME/.config}/hard-gaming-konsole.conf"

KONSOLE_BIN="/usr/share/opengamepadui/opengamepad-ui.$(uname -m)"
KONSOLE_LOG="${XDG_STATE_HOME:-$HOME/.local/state}/hard-gaming-konsole.log"
mkdir -p "${KONSOLE_LOG%/*}"

# Updates nur über das Hard Gaming Update Center
export OGUI_FEATURE_UPDATER=0

log() { printf '%s %s\n' "$(date '+%F %T')" "$*" >>"$KONSOLE_LOG"; }

# PCI-Kennungen (vendor:device) aller Grafikkarten
gpu_ids() { lspci -nn 2>/dev/null | grep -E 'VGA|3D|Display' | grep -oE '\[[0-9a-f]{4}:[0-9a-f]{4}\]' | tr -d '[]'; }

# gamescope-Option für die Render-GPU. Nie per VK_ICD_FILENAMES auf eine iGPU
# zwingen: kleine iGPUs laufen mit gamescope + Oberfläche aus dem Speicher.
gpu_args() {
  local ids nv other
  ids="$(gpu_ids)"
  nv="$(grep '^10de:' <<<"$ids" | head -n1)"
  other="$(grep -v '^10de:' <<<"$ids" | head -n1)"
  case "$KONSOLE_GPU" in
    igpu) [[ -n $other ]] && printf -- '--prefer-vk-device %s' "$other" ;;
    auto|dgpu|*) [[ -n $nv ]] && printf -- '--prefer-vk-device %s' "$nv" ;;
  esac
}

# Laptop mit NVIDIA und zusätzlicher (interner) Grafik?
is_hybrid() {
  local ids
  ids="$(gpu_ids)"
  grep -q '^10de:' <<<"$ids" && grep -qv '^10de:' <<<"$ids"
}

# PRIME-Offload: Programm auf der NVIDIA-Karte rendern lassen, Bild läuft über
# die interne Grafik. Standardweg für Hybrid-Laptops, ohne gamescope.
prime_env() {
  is_hybrid || return 0
  case "$KONSOLE_GPU" in
    igpu) return 0 ;;
  esac
  export __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia
}

# Sicherheitsprüfung vor dem Start. Gibt einen Grund aus und liefert 1, wenn die
# Konsole auf diesem Gerät voraussichtlich nicht sauber startet.
konsole_check() {
  command -v gamescope >/dev/null || { echo "gamescope fehlt"; return 1; }
  [[ -x $KONSOLE_BIN ]] || { echo "Konsolen-Programm fehlt ($KONSOLE_BIN)"; return 1; }
  command -v vulkaninfo >/dev/null && ! vulkaninfo --summary >/dev/null 2>&1 && { echo "keine Vulkan-fähige Grafik gefunden"; return 1; }
  if [[ -d /sys/module/nvidia ]]; then
    local ms
    ms="$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null)"
    [[ $ms == Y ]] || { echo "NVIDIA-Treiber ohne modeset=1 (gamescope braucht nvidia_drm.modeset=1)"; return 1; }
  fi
  return 0
}
