#!/usr/bin/env bash
# Baut nur die Pakete für den Umstieg von CachyOS (ohne ISO) nach dist/packages/.
# Aufruf als normaler Benutzer: ./scripts/build-umstieg.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$ROOT/scripts/build-packages.sh" "$ROOT/dist/packages"
echo
echo 'Fertig. Installieren auf einem CachyOS-System (vorher Backup!):'
echo "  sudo pacman -U $ROOT/dist/packages/hgos-branding-*.pkg.tar.* $ROOT/dist/packages/hgos-update-center-*.pkg.tar.* $ROOT/dist/packages/hgos-umstieg-*.pkg.tar.*"
