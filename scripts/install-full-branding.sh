#!/usr/bin/env bash
# HGOS 1.8.0 branding installer. Offline target root only; no host modifications.
set -euo pipefail
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[[ $# == 2 && "$1" == --target ]] || { echo "Usage: $0 --target /mounted/root" >&2; exit 2; }
TARGET="$(realpath -e -- "$2")"
[[ "$TARGET" != / && -d "$TARGET/etc" && -d "$TARGET/usr" ]] || { echo "Unsafe target" >&2; exit 3; }
install -d "$TARGET/usr/share/hard-gaming-os" "$TARGET/usr/share/backgrounds/hard-gaming-os" "$TARGET/usr/share/plymouth/themes/hard-gaming-os" "$TARGET/usr/share/sddm/themes/hard-gaming-os" "$TARGET/etc/sddm.conf.d" "$TARGET/etc/default/grub.d"
install -m644 "$BASE/assets/HG OS.png" "$TARGET/usr/share/hard-gaming-os/logo.png"
install -m644 "$BASE/assets/HG Labs.png" "$TARGET/usr/share/hard-gaming-os/labs.png"
install -m644 "$BASE/assets/HG OS Wallpaper.jpg" "$TARGET/usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg"
install -m644 "$BASE/assets/HG OS Wallpaper 2.jpg" "$TARGET/usr/share/backgrounds/hard-gaming-os/wallpaper-alternative.jpg"
install -m644 "$BASE/branding/full/os-release" "$TARGET/etc/os-release"
install -m644 "$BASE/branding/full/issue" "$TARGET/etc/issue"
install -m644 "$BASE/branding/full/plymouth.plymouth" "$TARGET/usr/share/plymouth/themes/hard-gaming-os/hard-gaming-os.plymouth"
install -m644 "$BASE/branding/full/hard-gaming-os.script" "$TARGET/usr/share/plymouth/themes/hard-gaming-os/hard-gaming-os.script"
install -m644 "$BASE/assets/HG OS.png" "$TARGET/usr/share/plymouth/themes/hard-gaming-os/logo.png"
install -m644 "$BASE/branding/full/Main.qml" "$TARGET/usr/share/sddm/themes/hard-gaming-os/Main.qml"
install -m644 "$BASE/assets/HG OS.png" "$TARGET/usr/share/sddm/themes/hard-gaming-os/logo.png"
install -m644 "$BASE/assets/HG OS Wallpaper.jpg" "$TARGET/usr/share/sddm/themes/hard-gaming-os/background.jpg"
install -m644 "$BASE/branding/full/theme.conf" "$TARGET/usr/share/sddm/themes/hard-gaming-os/theme.conf"
install -m644 "$BASE/branding/full/sddm.conf" "$TARGET/etc/sddm.conf.d/90-hard-gaming-os.conf"
printf 'GRUB_DISTRIBUTOR="Hard Gaming OS"\nGRUB_BACKGROUND="/usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg"\n' > "$TARGET/etc/default/grub.d/90-hard-gaming-os.cfg"
echo 'Branding payload installed; Plymouth initramfs, GRUB regeneration and login-manager compatibility require target-specific steps.'
