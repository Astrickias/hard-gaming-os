#!/usr/bin/env bash
# Baut die Hard-Gaming-Pakete (hgos-branding, hgos-update-center, …) mit makepkg.
# hgos-konsole (Fork von OpenGamepadUI) nur mit HGOS_BUILD_KONSOLE=1 – braucht Netz,
# Godot 4.7, Rust und dauert deutlich länger; gebaut wird es im GitHub-Workflow.
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

build_pkg() { # name [zusatzschritt]
  local name=$1 work="$ROOT/build/pkg/$1" flags=(-f --noconfirm)
  # HGOS_NUR_PAKET=name baut nur dieses eine Paket (z. B. im Workflow die Konsole getrennt).
  [[ -z ${HGOS_NUR_PAKET:-} || $HGOS_NUR_PAKET == "$name" ]] || return 0
  # Reine Daten-Pakete (arch=any) brauchen ihre Laufzeitabhängigkeiten nicht auf dem Buildhost.
  [[ $name == hgos-update-center ]] || flags+=(--nodeps)
  rm -rf -- "$work"; mkdir -p "$work"
  cp -a "$ROOT/packaging/$name/." "$work/"
  sed -i "s/@VERSION@/$VERSION/" "$work/PKGBUILD"
  [[ $# -lt 2 ]] || "$2" "$work"
  [[ ${#RUN_AS[@]} -eq 0 ]] || chown -R "$SUDO_USER": "$work"
  # Update Center ohne --nodeps: fehlende Build-Abhängigkeiten nennt makepkg mit Namen.
  if ! (cd "$work" && "${RUN_AS[@]}" env PKGDEST="$work/out" makepkg "${flags[@]}"); then
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

umstieg_extra() { # Systemkennung, Logos und Hello aus dem Projekt übernehmen
  local root="$1/root" stage="$ROOT/build/pkg/umstieg-stage"
  "$ROOT/scripts/prepare-edition.sh" gaming >/dev/null
  local overlay="$ROOT/build/gaming/overlay/usr/share/hard-gaming-os"
  install -d "$root/usr/bin" "$root/usr/share/hard-gaming-os" "$root/usr/share/applications" "$root/etc/xdg/autostart"
  for file in os-release issue release-info edition hg-os-logo.png hg-labs-logo.png hg-labs-outline.png; do
    install -m644 "$overlay/$file" "$root/usr/share/hard-gaming-os/$file"
  done
  install -m644 "$ROOT/overlay/usr/share/applications/hgos-about.desktop" "$root/usr/share/applications/"
  rm -rf -- "$stage"; mkdir -p "$stage"
  "$ROOT/scripts/install-hg-welcome.sh" "$stage" >/dev/null
  cp -a "$stage/usr/share/hard-gaming-os/welcome" "$root/usr/share/hard-gaming-os/"
  install -m755 "$stage/usr/local/bin/hg-welcome" "$stage/usr/local/bin/hgos-url" "$root/usr/bin/"
  for desktop in hg-welcome.desktop hgos-url.desktop; do
    sed 's#/usr/local/bin/#/usr/bin/#g' "$stage/usr/share/applications/$desktop" > "$root/usr/share/applications/$desktop"
  done
  sed 's#/usr/local/bin/#/usr/bin/#g' "$stage/etc/xdg/autostart/hg-welcome.desktop" > "$root/etc/xdg/autostart/hg-welcome.desktop"
}

keyring_extra() { # öffentlicher Schlüssel und Repo-Adresse
  cp -a "$ROOT/keys" "$1/keys"
  sed -i "s|@REPO_URL@|$HGOS_REPO_URL|" "$1/root/usr/lib/hard-gaming-os/pacman-repo"
}

konsole_extra() { # Hard-Gaming-Logo für Programmsymbol und Startvideo
  python3 - "$ROOT/assets/HG OS.png" "$1" <<'PY'
import sys
from pathlib import Path
from PIL import Image
src, work = Path(sys.argv[1]), Path(sys.argv[2])
img = Image.open(src).convert("RGBA")
img.resize((512, 512), Image.LANCZOS).save(work / "logo.png")
img.resize((256, 256), Image.LANCZOS).save(work / "logo-256.png")
PY
}

if [[ -s "$ROOT/keys/hardgaming.gpg" && -s "$ROOT/keys/hardgaming-trusted" ]]; then
  build_pkg hgos-keyring keyring_extra
else
  echo 'Hinweis: keys/hardgaming.gpg fehlt noch – hgos-keyring wird übersprungen (siehe docs/PAKET-REPO.md).' >&2
fi
build_pkg hgos-branding branding_extra
build_pkg hgos-update-center
build_pkg hgos-umstieg umstieg_extra
if [[ ${HGOS_BUILD_KONSOLE:-0} == 1 ]]; then
  build_pkg hgos-konsole konsole_extra
else
  echo 'Hinweis: hgos-konsole übersprungen (nur mit HGOS_BUILD_KONSOLE=1, siehe docs/KONSOLE.md).' >&2
fi
