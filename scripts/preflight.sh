#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for f in "$ROOT"/scripts/*.sh "$ROOT"/installer/*.sh; do bash -n "$f"; done
python3 -m unittest discover -s "$ROOT/tests" -p 'test_*.py'
python3 -m compileall -q "$ROOT/scripts"
for asset in 'HG OS.png' 'HG Labs.png' 'HG Labs BL.png' 'HG OS Wallpaper.jpg' 'HG OS Wallpaper 2.jpg'; do test -s "$ROOT/assets/$asset"; done
printf 'Statische Prüfungen erfolgreich. Kein ISO- oder Installationstest.\n'
