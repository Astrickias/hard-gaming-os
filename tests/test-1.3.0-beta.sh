#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "$ROOT/tests/test-1.2.0-beta.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/root/var/lib/pacman/local/steam-1" "$TMP/root/var/lib/pacman/local/lutris-1"
printf '%%NAME%%\nsteam\n' > "$TMP/root/var/lib/pacman/local/steam-1/desc"
printf '%%NAME%%\nlutris\n' > "$TMP/root/var/lib/pacman/local/lutris-1/desc"
printf 'steam\nlutris\n' > "$TMP/packages.txt"
python3 "$ROOT/scripts/audit-target-packages.py" "$TMP/root" "$TMP/packages.txt"
printf 'steam\nlutris\nheroic-games-launcher\n' > "$TMP/packages.txt"
if python3 "$ROOT/scripts/audit-target-packages.py" "$TMP/root" "$TMP/packages.txt"; then echo 'Fehlendes Paket nicht erkannt' >&2; exit 1; fi
if python3 "$ROOT/scripts/audit-target-packages.py" / "$TMP/packages.txt"; then echo 'Host-Root nicht verweigert' >&2; exit 1; fi
bash "$ROOT/scripts/prepare-calamares.sh" gaming >/dev/null
grep -Fq '@@ROOT@@' "$ROOT/build/gaming/calamares/integration/shellprocess-hgos.conf"
! grep -Fq '/tmp/hgos-target-root' "$ROOT/build/gaming/calamares/integration/shellprocess-hgos.conf"
python3 -m py_compile "$ROOT/scripts/audit-target-packages.py"
echo 'OK: 1.3.0 Paket-Audit, Negativtests, Calamares-Vorlage'
