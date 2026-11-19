#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for edition in gaming; do
 "$ROOT/scripts/prepare-edition.sh" "$edition"
 test -s "$ROOT/build/$edition/packages.txt"
 test -s "$ROOT/build/$edition/overlay/usr/share/hard-gaming-os/hg-os-logo.png"
 test -s "$ROOT/build/$edition/overlay/usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg"
 grep -qx "$edition" "$ROOT/build/$edition/overlay/usr/share/hard-gaming-os/edition"
done
! test -e "$ROOT/config/editions/allround.packages"
grep -qx kate "$ROOT/build/gaming/packages.txt"
! grep -qx libreoffice-fresh "$ROOT/config/editions/gaming.packages"
grep -qx steam "$ROOT/build/gaming/packages.txt"
for f in "$ROOT"/scripts/*.sh "$ROOT"/installer/*.sh; do bash -n "$f"; done
python3 -I -m unittest discover -s "$ROOT/tests" -p 'test_*.py' 2>&1 | tail -n 1
grep -q 'https://hardgaming.net/' "$ROOT/apps/hg-welcome/index.html"
grep -q 'hgos://install' "$ROOT/apps/hg-welcome/index.html"
grep -q 'hgos://update' "$ROOT/apps/hg-welcome/index.html"
grep -q 'basiert auf <a href="https://cachyos.org/">CachyOS</a>' "$ROOT/apps/hg-welcome/index.html"
for f in PKGBUILD hgos-branding.install root/usr/lib/hard-gaming-os/apply-branding \
         root/usr/share/grub/themes/hard-gaming-os/theme.txt root/usr/share/grub/themes/hard-gaming-os/background.png \
         root/usr/share/color-schemes/HardGaming.colors root/usr/share/wallpapers/HardGamingOS/metadata.json \
         root/usr/share/plasma/look-and-feel/org.hardgaming.desktop/contents/defaults root/etc/xdg/fastfetch/config.jsonc; do
  test -e "$ROOT/packaging/hgos-branding/$f" || { echo "Branding-Paket unvollständig: $f" >&2; exit 1; }
done
python3 -c 'import json,sys; [json.load(open(f)) for f in sys.argv[1:]]' \
  "$ROOT"/packaging/hgos-branding/root/usr/share/wallpapers/*/metadata.json \
  "$ROOT"/packaging/hgos-branding/root/usr/share/plasma/look-and-feel/org.hardgaming.desktop/metadata.json
grep -q '^  SidebarText:' "$ROOT/installer/calamares/branding/hardgamingos/branding.desc"
for f in "$ROOT"/apps/hg-welcome/hg-welcome "$ROOT"/apps/hg-welcome/hgos-url "$ROOT"/packaging/hgos-branding/root/usr/lib/hard-gaming-os/apply-branding; do bash -n "$f"; done
grep -q 'https://github.com/storytold/craft-launcher/releases' "$ROOT/apps/hg-welcome/index.html"
echo 'OK: Editionen, Assets, Pakettrennung, Shell-Syntax, Bootmenü-Diagnose, Hello und Branding-Paket'
