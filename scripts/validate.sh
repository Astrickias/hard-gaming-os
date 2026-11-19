#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for file in 'assets/HG OS.png' 'assets/HG Labs.png' 'assets/HG Labs BL.png' 'assets/HG OS Wallpaper.jpg' 'assets/HG OS Wallpaper 2.jpg' 'config/common.packages' 'config/editions/gaming.packages' 'config/editions/allround.packages'; do
 [[ -s "$ROOT/$file" ]] || { echo "FEHLT: $file" >&2; exit 1; }
done
for edition in gaming; do
 "$ROOT/scripts/prepare-edition.sh" "$edition"
 test -s "$ROOT/build/$edition/packages.txt"
 test -s "$ROOT/build/$edition/overlay/usr/share/hard-gaming-os/hg-os-logo.png"
 [[ "$(cat "$ROOT/build/$edition/overlay/usr/share/hard-gaming-os/edition")" == "$edition" ]]
done
printf 'OK: Beide Editionen staged; ISO-Build und Boot nicht getestet.\n'
