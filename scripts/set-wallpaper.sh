#!/usr/bin/env bash
set -euo pipefail
WALLPAPER="/usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg"
if [[ "${1:-}" == '--alternative' ]]; then WALLPAPER="/usr/share/backgrounds/hard-gaming-os/wallpaper-alternative.jpg"; fi
if ! command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
  echo 'KDE Plasma-Werkzeug plasma-apply-wallpaperimage nicht gefunden.' >&2; exit 1
fi
exec plasma-apply-wallpaperimage "$WALLPAPER"
