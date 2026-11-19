#!/usr/bin/env bash
# Installiert nur das Calamares-Branding in ein bereits vorbereitetes Live-Root.
# Bestehende Sequenzen, Installer-Pakete und Partitionierung bleiben unverändert.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"
[[ -n "$TARGET" && -d "$TARGET/etc" && -d "$TARGET/usr" ]] || { echo 'Aufruf: install-calamares-branding.sh LIVE-ROOT' >&2; exit 2; }
TARGET="$(realpath -e -- "$TARGET")"
[[ "$TARGET" != / ]] || { echo 'Installation in / gesperrt' >&2; exit 2; }
SOURCE="$ROOT/installer/calamares/branding/hardgamingos"
DEST="$TARGET/usr/share/calamares/branding/hardgamingos"
[[ ! -e "$DEST" ]] || { echo "Branding existiert bereits: $DEST" >&2; exit 3; }
mkdir -p "$(dirname "$DEST")"
cp -a -- "$SOURCE" "$DEST"
# CachyOS kopiert beim Online-Start settings_online.conf nach /etc/calamares/settings.conf.
# Deshalb nur existierende Settings-Dateien patchen, keine neuen Abläufe erfinden.
found=0
for conf in "$TARGET/usr/share/calamares/settings.conf" "$TARGET/usr/share/calamares/settings_online.conf" "$TARGET/usr/share/calamares/settings_offline.conf" "$TARGET/etc/calamares/settings.conf"; do
  [[ -f "$conf" ]] || continue
  found=1
  if grep -Eq '^branding:[[:space:]]*cachyos[[:space:]]*$' "$conf"; then
    sed -i -E 's/^branding:[[:space:]]*cachyos[[:space:]]*$/branding: hardgamingos/' "$conf"
  elif ! grep -Eq '^branding:[[:space:]]*hardgamingos[[:space:]]*$' "$conf"; then
    echo "Unbekannte Branding-Konfiguration: $conf" >&2; exit 4
  fi
done
[[ "$found" == 1 ]] || { echo 'Keine Calamares-Settings gefunden; Branding installiert, Aktivierung noch ausstehend' >&2; exit 5; }
echo 'Hard Gaming OS Calamares-Branding aktiviert (Installationssequenz unverändert).'
