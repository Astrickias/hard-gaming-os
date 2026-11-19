#!/usr/bin/env bash
# Baut hgos-branding als pacman-Paket. Muss auf einem Arch/CachyOS-Host laufen.
# Aufruf: build-branding-package.sh AUSGABEVERZEICHNIS
# Unter sudo wird makepkg als aufrufender Benutzer ($SUDO_USER) ausgeführt.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:?Ausgabeverzeichnis fehlt}"
source "$ROOT/config/release.env"
VERSION="${HGOS_VERSION%%-*}"
command -v makepkg >/dev/null || { echo 'makepkg fehlt' >&2; exit 3; }
WORK="$ROOT/build/pkg/hgos-branding"
rm -rf -- "$WORK"; mkdir -p "$WORK" "$OUT"
cp -a "$ROOT/packaging/hgos-branding/." "$WORK/"
sed -i "s/@VERSION@/$VERSION/" "$WORK/PKGBUILD"
THEME="$WORK/root/usr/share/plymouth/themes/hard-gaming-os"
install -Dm644 "$ROOT/branding/full/plymouth.plymouth" "$THEME/hard-gaming-os.plymouth"
install -m644 "$ROOT/branding/full/hard-gaming-os.script" "$THEME/hard-gaming-os.script"
install -m644 "$ROOT/assets/HG OS.png" "$THEME/logo.png"
run=(makepkg -f --nodeps --noconfirm)
if [[ $(id -u) -eq 0 ]]; then
  [[ -n "${SUDO_USER:-}" && "$SUDO_USER" != root ]] || { echo 'makepkg nicht als root: Build per sudo von einem normalen Benutzer starten' >&2; exit 3; }
  chown -R "$SUDO_USER": "$WORK"
  (cd "$WORK" && sudo -u "$SUDO_USER" env PKGDEST="$WORK/out" "${run[@]}")
else
  (cd "$WORK" && env PKGDEST="$WORK/out" "${run[@]}")
fi
pkg=("$WORK"/out/hgos-branding-"$VERSION"-1-any.pkg.tar.*)
[[ -f "${pkg[0]}" ]] || { echo 'Branding-Paket wurde nicht erzeugt' >&2; exit 4; }
install -m644 "${pkg[0]}" "$OUT/"
printf 'Branding-Paket: %s\n' "$OUT/${pkg[0]##*/}"
