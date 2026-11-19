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
if test -e "$ROOT/config/editions/allround.packages"; then
  echo "Veraltete Allround-Edition vorhanden" >&2
  exit 1
fi
grep -qx kate "$ROOT/build/gaming/packages.txt"
if grep -qx libreoffice-fresh "$ROOT/config/editions/gaming.packages"; then
  echo "LibreOffice muss optional bleiben" >&2
  exit 1
fi
grep -qx steam "$ROOT/build/gaming/packages.txt"
for f in "$ROOT"/scripts/*.sh "$ROOT"/installer/*.sh; do bash -n "$f"; done
python3 -I -m unittest discover -s "$ROOT/tests" -p 'test_*.py' 2>&1 | tail -n 1
grep -q 'https://hardgaming.net/' "$ROOT/apps/hg-welcome/index.html"
grep -q 'hgos://install' "$ROOT/apps/hg-welcome/index.html"
grep -q 'hgos://update' "$ROOT/apps/hg-welcome/index.html"
grep -q 'basiert auf <a href="https://cachyos.org/">CachyOS</a>' "$ROOT/apps/hg-welcome/index.html"
for f in ../hgos-update-center/PKGBUILD ../hgos-update-center/hgos-update-center.install ../hgos-update-center/brand-update-center.py \
         ../hgos-update-center/assets/logo.svg ../hgos-update-center/assets/tray-uptodate.svg ../hgos-update-center/assets/tray-updates.svg \
         ../hgos-keyring/PKGBUILD ../hgos-keyring/hgos-keyring.install ../hgos-keyring/root/usr/lib/hard-gaming-os/pacman-repo \
         ../hgos-umstieg/PKGBUILD ../hgos-umstieg/hgos-umstieg.install \
         root/usr/lib/hard-gaming-os/restore-branding root/usr/bin/hgos-design-anwenden root/usr/bin/hgos-design-zuruecksetzen \
         PKGBUILD hgos-branding.install root/usr/lib/hard-gaming-os/apply-branding \
         root/usr/share/grub/themes/hard-gaming-os/theme.txt root/usr/share/grub/themes/hard-gaming-os/background.png \
         root/usr/share/color-schemes/HardGaming.colors root/usr/share/wallpapers/HardGamingOS/metadata.json \
         root/usr/share/plasma/look-and-feel/org.hardgaming.desktop/contents/defaults root/etc/xdg/fastfetch/config.jsonc; do
  test -e "$ROOT/packaging/hgos-branding/$f" || { echo "Branding-Paket unvollständig: $f" >&2; exit 1; }
done
python3 -c 'import json,sys; [json.load(open(f)) for f in sys.argv[1:]]' \
  "$ROOT"/packaging/hgos-branding/root/usr/share/wallpapers/*/metadata.json \
  "$ROOT"/packaging/hgos-branding/root/usr/share/plasma/look-and-feel/org.hardgaming.desktop/metadata.json
grep -q '_commit=3011d681a65f2bb8d3193f39c384bdf75094db2b' "$ROOT/packaging/hgos-update-center/PKGBUILD"
python3 -I -m py_compile "$ROOT/packaging/hgos-update-center/brand-update-center.py"
grep -qx pacman-contrib "$ROOT/config/editions/gaming.packages"
grep -q '^  SidebarText:' "$ROOT/installer/calamares/branding/hardgamingos/branding.desc"
test -s "$ROOT/apps/hg-welcome/qml/Main.qml"
grep -q 'hgos://install' "$ROOT/apps/hg-welcome/qml/Main.qml"
grep -q 'hgos://update' "$ROOT/apps/hg-welcome/qml/Main.qml"
for f in "$ROOT"/apps/hg-welcome/hg-welcome "$ROOT"/apps/hg-welcome/hgos-url "$ROOT"/packaging/hgos-branding/root/usr/lib/hard-gaming-os/* "$ROOT"/packaging/hgos-branding/root/usr/bin/* "$ROOT"/packaging/*/*.install; do bash -n "$f"; done
grep -q 'pre_remove' "$ROOT/packaging/hgos-branding/hgos-branding.install"
bash -n "$ROOT/packaging/hgos-keyring/root/usr/lib/hard-gaming-os/pacman-repo"
python3 -c 'import sys,yaml; yaml.safe_load(open(sys.argv[1]))' "$ROOT/.github/workflows/pakete.yml" 2>/dev/null || python3 -c 'import sys; open(sys.argv[1]).read()' "$ROOT/.github/workflows/pakete.yml"
grep -q '^HGOS_REPO_URL=' "$ROOT/config/release.env"
grep -q 'https://github.com/storytold/craft-launcher/releases' "$ROOT/apps/hg-welcome/index.html"
# Hard Gaming Konsole (hgos-konsole)
K="$ROOT/packaging/hgos-konsole"
for f in PKGBUILD hgos-konsole.install brand-konsole.py root/usr/bin/hard-gaming-konsole root/usr/bin/hgos-konsole-beenden root/usr/lib/hard-gaming-os/konsole-session \
         root/usr/lib/hard-gaming-os/konsole-common.sh root/etc/hard-gaming-os/konsole.conf \
         root/usr/share/wayland-sessions/hard-gaming-konsole.desktop root/usr/share/applications/hard-gaming-konsole.desktop; do
  test -e "$K/$f" || { echo "Konsolen-Paket unvollständig: $f" >&2; exit 1; }
done
for f in "$K"/root/usr/bin/hard-gaming-konsole "$K"/root/usr/lib/hard-gaming-os/konsole-*; do bash -n "$f"; done
python3 -I -m py_compile "$K/brand-konsole.py"
grep -q '_ogui_commit=a79179dc5bc737b3ccaf2b7f66bd67d76f615e4c' "$K/PKGBUILD"
grep -q 'OGUI_FEATURE_UPDATER=0' "$K/root/usr/lib/hard-gaming-os/konsole-common.sh"
if grep -Eq '^[[:space:]]*([^#[:space:]].*)?VK_ICD_FILENAMES=' "$K"/root/usr/lib/hard-gaming-os/konsole-* "$K/root/usr/bin/hard-gaming-konsole"; then
  echo "Konsolenstart erzwingt einen Vulkan-Treiber" >&2
  exit 1
fi
grep -q 'hgos://konsole' "$ROOT/apps/hg-welcome/qml/Main.qml"
grep -q 'hgos://konsole' "$ROOT/apps/hg-welcome/hgos-url"
echo 'OK: Editionen, Assets, Pakettrennung, Shell-Syntax, Bootmenü-Diagnose, Hello, Branding-Paket, Update Center, Hello-App, Umstiegspaket, Paket-Repo und Konsole'
