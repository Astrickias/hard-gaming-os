#!/usr/bin/env bash
# Wird NUR nach erfolgreicher Rootfs-Installation aus Calamares ausgeführt.
# Konservativer Hook: Editionspakete vor Branding pruefen, KEINE Paketinstallation.
set -euo pipefail
EDITION="${1:-}"
TARGET="${2:-}"
[[ "$EDITION" == gaming || "$EDITION" == allround ]] || { echo 'Ungültige Edition' >&2; exit 2; }
[[ -n "$TARGET" && -d "$TARGET/etc" && -d "$TARGET/usr" ]] || { echo 'Ungültiges Zielroot' >&2; exit 2; }
TARGET="$(realpath -e -- "$TARGET")"
[[ "$TARGET" != / ]] || exit 2
PAYLOAD="/usr/share/hard-gaming-os/target-payload/$EDITION"
[[ -d "$PAYLOAD" ]] || { echo "Payload fehlt: $PAYLOAD" >&2; exit 3; }
# Installation muss die Pakete bereits bereitgestellt haben. Fail closed.
MANIFEST="/usr/share/hard-gaming-os/manifests/$EDITION.packages"
AUDIT="/usr/local/libexec/hgos-audit-target-packages"
[[ -f "$MANIFEST" && -x "$AUDIT" ]] || { echo 'HGOS: Audit oder Paketmanifest fehlt' >&2; exit 5; }
"$AUDIT" "$TARGET" "$MANIFEST" || { echo 'HGOS: Editionspakete fehlen; Installation nicht als erfolgreich markieren' >&2; exit 6; }
# Vorab auf Konflikte prüfen, damit keine gemischten Zustände entstehen.
while IFS= read -r -d '' FILE; do
 REL="${FILE#"$PAYLOAD"/}"
 DEST="$TARGET/$REL"
 if [[ -e "$DEST" || -L "$DEST" ]]; then
   cmp -s -- "$FILE" "$DEST" || { echo "Dateikonflikt: $REL" >&2; exit 4; }
 fi
done < <(find "$PAYLOAD" -type f -print0)
cp -an -- "$PAYLOAD/." "$TARGET/"
SHARE="$TARGET/usr/share/hard-gaming-os"
for file in os-release issue; do
  TEMP="$(mktemp "$TARGET/etc/.hgos-$file.XXXXXX")"
  install -m644 "$SHARE/$file" "$TEMP"
  mv -Tf -- "$TEMP" "$TARGET/etc/$file"
done
LOGIN="$TARGET/etc/plasmalogin.conf"
kwriteconfig6 --file "$LOGIN" --group Greeter --key WallpaperPluginId org.kde.image
kwriteconfig6 --file "$LOGIN" --group Greeter --group Wallpaper --group org.kde.image --group General \
  --key Image file:///usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg
printf 'Hard Gaming OS: Branding %s nach %s übertragen\n' "$EDITION" "$TARGET"
