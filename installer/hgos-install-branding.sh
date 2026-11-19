#!/usr/bin/env bash
# Installiert hgos-branding ins Zielsystem (Calamares, dontChroot, vor plymouthcfg).
# Ersetzt per provides/conflicts die CachyOS-Grafikpakete. Ist es schon da: nichts tun.
set -euo pipefail
TARGET="${1:-}"
[[ -n "$TARGET" && -d "$TARGET/etc" && "$(realpath -e -- "$TARGET")" != / ]] || { echo 'HGOS: ungültiges Zielroot' >&2; exit 2; }
if chroot "$TARGET" pacman -Q hgos-branding >/dev/null 2>&1; then
  echo 'HGOS: hgos-branding bereits installiert'; exit 0
fi
mapfile -t PKGS < <(find /usr/share/hard-gaming-os/packages -maxdepth 1 -name 'hgos-branding-*.pkg.tar.*' ! -name '*.sig' 2>/dev/null)
[[ ${#PKGS[@]} -eq 1 ]] || { echo "HGOS: Branding-Paket nicht eindeutig (${#PKGS[@]} gefunden)" >&2; exit 7; }
install -d "$TARGET/var/cache/hard-gaming-os"
install -m644 "${PKGS[0]}" /usr/share/hard-gaming-os/pacman-local.conf "$TARGET/var/cache/hard-gaming-os/"
# --ask=4 beantwortet die Frage nach dem Entfernen kollidierender Pakete mit Ja.
chroot "$TARGET" pacman --config /var/cache/hard-gaming-os/pacman-local.conf -U --noconfirm --ask=4 "/var/cache/hard-gaming-os/${PKGS[0]##*/}" \
  || { echo 'HGOS: Branding-Paket konnte nicht installiert werden' >&2; exit 7; }
echo "HGOS: Branding-Paket installiert: ${PKGS[0]##*/}"
