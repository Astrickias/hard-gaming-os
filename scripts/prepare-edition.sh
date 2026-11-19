#!/usr/bin/env bash
set -euo pipefail
usage() { echo "Aufruf: $0 gaming|allround [--output VERZEICHNIS]" >&2; exit 2; }
[[ $# -ge 1 ]] || usage
EDITION="$1"; shift
[[ "$EDITION" == gaming || "$EDITION" == allround ]] || usage
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/config/release.env"
OUT="$ROOT/build/$EDITION"
if [[ $# -gt 0 ]]; then [[ $# -eq 2 && "$1" == '--output' ]] || usage; OUT="$2"; fi
[[ "$OUT" != / && -n "$OUT" ]] || { echo 'Unsicheres Ausgabeziel' >&2; exit 2; }
mkdir -p "$OUT/overlay/usr/share/hard-gaming-os" "$OUT/overlay/usr/share/backgrounds/hard-gaming-os" "$OUT/overlay/usr/share/pixmaps"
cp -a "$ROOT/overlay/." "$OUT/overlay/"
install -m 0644 "$ROOT/assets/HG OS.png" "$OUT/overlay/usr/share/hard-gaming-os/hg-os-logo.png"
install -m 0644 "$ROOT/assets/HG Labs.png" "$OUT/overlay/usr/share/hard-gaming-os/hg-labs-logo.png"
install -m 0644 "$ROOT/assets/HG Labs BL.png" "$OUT/overlay/usr/share/hard-gaming-os/hg-labs-outline.png"
install -m 0644 "$ROOT/assets/HG OS Wallpaper.jpg" "$OUT/overlay/usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg"
install -m 0644 "$ROOT/assets/HG OS Wallpaper 2.jpg" "$OUT/overlay/usr/share/backgrounds/hard-gaming-os/wallpaper-alternative.jpg"
install -m 0644 "$ROOT/branding/hard-gaming-os-release" "$OUT/overlay/usr/share/hard-gaming-os/release-info"
printf '%s\n' "$EDITION" > "$OUT/overlay/usr/share/hard-gaming-os/edition"
case "$EDITION" in
  gaming) EDITION_NAME="Gaming Edition" ;;
  allround) EDITION_NAME="Allround Edition" ;;
esac
sed "s/^PRETTY_NAME=.*/PRETTY_NAME=\"Hard Gaming OS $EDITION_NAME\"/" \
  "$ROOT/branding/full/os-release" > "$OUT/overlay/usr/share/hard-gaming-os/os-release"
install -Dm644 "$ROOT/branding/full/issue" "$OUT/overlay/usr/share/hard-gaming-os/issue"
install -Dm644 "$ROOT/branding/full/plasma-login.conf" "$OUT/overlay/usr/share/hard-gaming-os/plasma-login.conf"
install -Dm644 "$ROOT/branding/full/plasma-wallpaper.desktop" "$OUT/overlay/etc/xdg/autostart/hgos-plasma-wallpaper.desktop"
install -Dm755 "$ROOT/branding/full/hgos-plasma-wallpaper" "$OUT/overlay/usr/local/libexec/hgos-plasma-wallpaper"
# Plymouth-Theme, GRUB-Theme, Wallpaper-Pakete und Plasma-Design liefert ab 2.1.6 das Paket hgos-branding.

{ cat "$ROOT/config/common.packages"; cat "$ROOT/config/editions/$EDITION.packages"; } | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' | LC_ALL=C sort -u > "$OUT/packages.txt"
cat > "$OUT/BUILD-NOTES.txt" <<EOF
Hard Gaming OS $HGOS_VERSION – $EDITION
Dieses Verzeichnis ist ein staging artifact, KEIN ISO.
Overlay: overlay/ (in das Live- und installierte Root-Dateisystem integrieren)
Pakete: packages.txt (mit offiziellem CachyOS-Profil abgleichen)
Upstream CachyOS-Profil, mkarchiso-Aufruf, Calamares-Module und Bootkonfiguration
müssen anhand eines festgelegten offiziellen Upstream-Commits integriert werden.
EOF
printf 'Edition %s vorbereitet: %s\n' "$EDITION" "$OUT"
