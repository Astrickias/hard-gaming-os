#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UP="$ROOT/build/hg-update-center/upstream"
[[ -d "$UP/native" ]] || { echo "Updater-Quellcode fehlt: $UP" >&2; exit 1; }
[[ -x "$UP/build-hg/cachyos-updater" ]] || { echo "Binary fehlt. Bitte erst cmake --build ausführen." >&2; exit 1; }
OUT="$ROOT/build/hg-update-center/branding-audit.txt"
mkdir -p "$(dirname "$OUT")"
{
 echo '=== QML-Texte / sichtbare Branding-Hinweise ==='
 grep -RInE 'Cachy(OS| Updater)|cachy(os|-updater)|window\.title|title:|icon\.(source|name)' "$UP/native/qml" --include='*.qml' | head -120 || true
 echo '=== Logo-Kopien ==='
 find "$UP/native" -iname '*hgos*' -o -iname '*logo*' | head -50
 echo '=== Desktop-Dateien ==='
 find "$UP" -name '*.desktop' -print
} | tee "$OUT"
echo "Audit gespeichert: $OUT"
echo 'Starte Updater ohne root. Keine Updates ausführen, bis die Oberfläche geprüft wurde.'
exec "$UP/build-hg/cachyos-updater"
