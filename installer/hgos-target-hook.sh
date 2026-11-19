#!/usr/bin/env bash
# Wird NUR nach erfolgreicher Rootfs-Installation aus Calamares ausgeführt (dontChroot).
# Reihenfolge: Editionspakete prüfen → HG-Branding-Paket installieren → sichtbare
# CachyOS-Programme entfernen → Payload kopieren → GRUB und initramfs neu erzeugen.
set -euo pipefail
EDITION="${1:-}"
TARGET="${2:-}"
[[ "$EDITION" == gaming ]] || { echo 'Ungültige Edition' >&2; exit 2; }
[[ -n "$TARGET" && -d "$TARGET/etc" && -d "$TARGET/usr" ]] || { echo 'Ungültiges Zielroot' >&2; exit 2; }
TARGET="$(realpath -e -- "$TARGET")"
[[ "$TARGET" != / ]] || exit 2
install -d "$TARGET/var/log"
exec > >(tee -a "$TARGET/var/log/hard-gaming-os-install.log") 2>&1
log() { printf 'HGOS: %s\n' "$*"; }
in_target() { chroot "$TARGET" "$@"; }
PAYLOAD="/usr/share/hard-gaming-os/target-payload/$EDITION"
[[ -d "$PAYLOAD" ]] || { echo "Payload fehlt: $PAYLOAD" >&2; exit 3; }

# 1) Installation muss die Editionspakete bereits bereitgestellt haben. Fail closed.
MANIFEST="/usr/share/hard-gaming-os/manifests/$EDITION.packages"
AUDIT="/usr/local/libexec/hgos-audit-target-packages"
[[ -f "$MANIFEST" && -x "$AUDIT" ]] || { echo 'HGOS: Audit oder Paketmanifest fehlt' >&2; exit 5; }
"$AUDIT" "$TARGET" "$MANIFEST" || { echo 'HGOS: Editionspakete fehlen; Installation nicht als erfolgreich markieren' >&2; exit 6; }

# 2) Branding-Paket (normalerweise schon vor plymouthcfg installiert, hier nur Absicherung).
/usr/local/libexec/hgos-install-branding "$TARGET"

# 2b) Hard Gaming Update Center (ersetzt per conflicts einen eventuell installierten cachyos-updater).
mapfile -t UPD < <(find /usr/share/hard-gaming-os/packages -maxdepth 1 -name 'hgos-update-center-*.pkg.tar.*' ! -name '*.sig' 2>/dev/null)
[[ ${#UPD[@]} -eq 1 ]] || { echo "HGOS: Update-Center-Paket nicht eindeutig (${#UPD[@]} gefunden)" >&2; exit 7; }
install -m644 "${UPD[0]}" "$TARGET/var/cache/hard-gaming-os/"
in_target pacman --config /var/cache/hard-gaming-os/pacman-local.conf -U --noconfirm --ask=4 "/var/cache/hard-gaming-os/${UPD[0]##*/}" \
  || { echo 'HGOS: Update Center konnte nicht installiert werden (Abhängigkeiten im Zielsystem?)' >&2; exit 7; }
log "Update Center installiert: ${UPD[0]##*/}"

# 2c) Schlüsselbund und Paket-Repo [hardgaming] (sofern im Build vorhanden).
mapfile -t KEYRING < <(find /usr/share/hard-gaming-os/packages -maxdepth 1 -name 'hgos-keyring-*.pkg.tar.*' ! -name '*.sig' 2>/dev/null)
if [[ ${#KEYRING[@]} -eq 1 ]]; then
  install -m644 "${KEYRING[0]}" "$TARGET/var/cache/hard-gaming-os/"
  in_target pacman --config /var/cache/hard-gaming-os/pacman-local.conf -U --noconfirm "/var/cache/hard-gaming-os/${KEYRING[0]##*/}" \
    || { echo 'HGOS: Schlüsselbund konnte nicht installiert werden' >&2; exit 7; }
  log "Paket-Repo eingerichtet: ${KEYRING[0]##*/}"
else
  log 'WARNUNG: hgos-keyring nicht im Build, Paket-Repo [hardgaming] nicht eingerichtet'
fi

# 3) Sichtbare CachyOS-Programme entfernen (nicht Kernel, Repos, Schlüssel, Einstellungen).
VISIBLE=(cachyos-hello cachyos-kernel-manager cachyos-packageinstaller cachyos-wallpapers cachy-update
         cachyos-kde-settings cachyos-emerald-kde-theme-git cachyos-nord-kde-theme-git)
REMOVE=()
for package in "${VISIBLE[@]}"; do
  in_target pacman -Q "$package" >/dev/null 2>&1 && REMOVE+=("$package")
done
if (( ${#REMOVE[@]} )); then
  if in_target pacman --config /var/cache/hard-gaming-os/pacman-local.conf -R --noconfirm "${REMOVE[@]}"; then
    log "Entfernt: ${REMOVE[*]}"
  else
    log "WARNUNG: konnte nicht entfernen (Abhängigkeit): ${REMOVE[*]}"
  fi
fi

# 4) HG-Payload. Vorab auf Konflikte prüfen, damit keine gemischten Zustände entstehen.
while IFS= read -r -d '' FILE; do
 REL="${FILE#"$PAYLOAD"/}"
 DEST="$TARGET/$REL"
 if [[ -e "$DEST" || -L "$DEST" ]]; then
   cmp -s -- "$FILE" "$DEST" || { echo "Dateikonflikt: $REL" >&2; exit 4; }
 fi
done < <(find "$PAYLOAD" -type f -print0)
cp -an -- "$PAYLOAD/." "$TARGET/"
# mkarchiso übernimmt Dateirechte nicht: Programme im Payload wieder ausführbar machen.
while IFS= read -r -d '' FILE; do
  chmod 755 "$TARGET/${FILE#"$PAYLOAD"/}"
done < <(find "$PAYLOAD/usr/local/bin" "$PAYLOAD/usr/local/libexec" -type f -print0 2>/dev/null)
LOGIN="$TARGET/etc/plasmalogin.conf"
kwriteconfig6 --file "$LOGIN" --group Greeter --key WallpaperPluginId org.kde.image
kwriteconfig6 --file "$LOGIN" --group Greeter --group Wallpaper --group org.kde.image --group General \
  --key Image file:///usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg

# Calamares legt den Benutzer vor diesem Hook an: HG-Design auch ins bestehende Home übernehmen.
for home in "$TARGET"/home/*/; do
  [[ -d "$home" ]] || continue
  owner="$(stat -c '%u:%g' "$home")"
  install -d -o "${owner%%:*}" -g "${owner##*:}" "$home.config"
  kwriteconfig6 --file "$home.config/kdeglobals" --group KDE --key LookAndFeelPackage org.hardgaming.desktop
  kwriteconfig6 --file "$home.config/kdeglobals" --group General --key ColorScheme HardGaming
  kwriteconfig6 --file "$home.config/kdeglobals" --group Icons --key Theme breeze-dark
  chown "$owner" "$home.config/kdeglobals"
done

# 5) os-release, lsb-release, issue, GRUB-Name/-Theme, Plymouth-Theme setzen.
in_target /usr/lib/hard-gaming-os/apply-branding
log 'Systemkennung, GRUB- und Plymouth-Einstellungen gesetzt'

# 6) GRUB-Menü und initramfs mit HG-Branding neu erzeugen.
if [[ -f "$TARGET/boot/grub/grub.cfg" ]] && in_target command -v grub-mkconfig >/dev/null; then
  in_target grub-mkconfig -o /boot/grub/grub.cfg || log 'WARNUNG: grub-mkconfig fehlgeschlagen, bisheriges Menü bleibt'
fi
in_target mkinitcpio -P || { echo 'HGOS: mkinitcpio fehlgeschlagen' >&2; exit 8; }

printf 'Hard Gaming OS: Branding %s nach %s übertragen\n' "$EDITION" "$TARGET"
