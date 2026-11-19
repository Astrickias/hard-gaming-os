#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for edition in gaming allround; do
 "$ROOT/scripts/prepare-edition.sh" "$edition"
 test -s "$ROOT/build/$edition/packages.txt"
 test -s "$ROOT/build/$edition/overlay/usr/share/hard-gaming-os/hg-os-logo.png"
 test -s "$ROOT/build/$edition/overlay/usr/share/backgrounds/hard-gaming-os/wallpaper-default.jpg"
 grep -qx "$edition" "$ROOT/build/$edition/overlay/usr/share/hard-gaming-os/edition"
done
! grep -qx steam "$ROOT/build/allround/packages.txt"
grep -qx steam "$ROOT/build/gaming/packages.txt"
for f in "$ROOT"/scripts/*.sh; do bash -n "$f"; done
echo 'OK: Editionen, Assets, Pakettrennung und Shell-Syntax'
