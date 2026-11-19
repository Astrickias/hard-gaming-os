#!/usr/bin/env bash
# Baut die Hard-Gaming-Pakete (hgos-branding, hgos-update-center) mit makepkg.
# Muss auf einem Arch/CachyOS-Host laufen. Aufruf: build-packages.sh AUSGABEVERZEICHNIS
# Unter sudo läuft makepkg als aufrufender Benutzer ($SUDO_USER).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:?Ausgabeverzeichnis fehlt}"
source "$ROOT/config/release.env"
VERSION="${HGOS_VERSION%%-*}"
command -v makepkg >/dev/null || { echo 'makepkg fehlt (base-devel installieren)' >&2; exit 3; }
mkdir -p "$OUT"
RUN_AS=()
if [[ $(id -u) -eq 0 ]]; then
  [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != root ]] || { echo 'makepkg nicht als root: Build per sudo von einem normalen Benutzer starten' >&2; exit 3; }
  RUN_AS=(sudo -u "$SUDO_USER")
fi

build_pkg() { # name zusatzschritt
  local name=$1 work="$ROOT/build/pkg/$1"
  rm -rf -- "$work"; mkdir -p "$work"
  cp -a "$ROOT/packaging/$name/." "$work/"
  sed -i "s/@VERSION@/$VERSION/" "$work/PKGBUILD"
  [[ $# -lt 2 ]] || "$2" "$work"
  [[ ${#RUN_AS[@]} -eq 0 ]] || chown -R "$SUDO_USER": "$work"
  # Ohne --nodeps: fehlende Build-Abhängigkeiten nennt makepkg mit Namen.
  if ! (cd "$work" && "${RUN_AS[@]}" env PKGDEST="$work/out" makepkg -f --noconfirm); then
    echo "Paketbau $name fehlgeschlagen. Fehlende Pakete stehen oben unter 'Missing dependencies'." >&2
    echo 'Build-Abhängigkeiten: sudo pacman -S --needed base-devel cmake ninja git kirigami qqc2-desktop-style pacman-contrib expac' >&2
    exit 4
  fi
  local pkg=("$work"/out/"$name"-"$VERSION"-1-*.pkg.tar.*)
  [[ -f "${pkg[0]}" ]] || { echo "Paket $name wurde nicht erzeugt" >&2; exit 4; }
  install -m644 "${pkg[0]}" "$OUT/"
  printf 'Paket: %s\n' "$OUT/${pkg[0]##*/}"
}

branding_extra() { # Plymouth-Theme aus branding/full und assets ergänzen
  local theme="$1/root/usr/share/plymouth/themes/hard-gaming-os"
  install -Dm644 "$ROOT/branding/full/plymouth.plymouth" "$theme/hard-gaming-os.plymouth"
  install -m644 "$ROOT/branding/full/hard-gaming-os.script" "$theme/hard-gaming-os.script"
  install -m644 "$ROOT/assets/HG OS.png" "$theme/logo.png"
}

build_pkg hgos-branding branding_extra
build_pkg hgos-update-center
