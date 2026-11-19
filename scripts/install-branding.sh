#!/usr/bin/env bash
set -euo pipefail
if (( EUID != 0 )); then echo 'Bitte mit sudo ausführen.' >&2; exit 1; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
install -d /usr/share/hard-gaming-os /usr/share/backgrounds/hard-gaming-os /usr/share/pixmaps
install -m 0644 "$ROOT/assets/HG OS.png" /usr/share/hard-gaming-os/hg-os-logo.png
install -m 0644 "$ROOT/assets/HG Labs.png" /usr/share/hard-gaming-os/hg-labs-logo.png
install -m 0644 "$ROOT/assets/HG Labs BL.png" /usr/share/hard-gaming-os/hg-labs-outline.png
install -m 0644 "$ROOT/assets/HG OS Wallpaper.jpg" /usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg
install -m 0644 "$ROOT/assets/HG OS Wallpaper 2.jpg" /usr/share/backgrounds/hard-gaming-os/wallpaper-alternative.jpg
install -m 0644 "$ROOT/branding/hard-gaming-os-release" /usr/share/hard-gaming-os/release-info
printf 'Branding installiert. OS-Identität und Paketquellen wurden nicht verändert.\n'
