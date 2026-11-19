#!/usr/bin/env bash
# Erzeugt eine nachvollziehbare Calamares-Integrationsvorlage, ohne Upstream zu überschreiben.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EDITION="${1:-}"
[[ "$EDITION" == gaming ]] || { echo 'Aufruf: prepare-calamares.sh gaming' >&2; exit 2; }
"$ROOT/scripts/prepare-edition.sh" "$EDITION" >/dev/null
OUT="$ROOT/build/$EDITION/calamares"
mkdir -p "$OUT/usr/share/hard-gaming-os/target-payload/$EDITION" "$OUT/usr/local/libexec" "$OUT/usr/share/hard-gaming-os/manifests" "$OUT/integration"
cp -a "$ROOT/build/$EDITION/overlay/." "$OUT/usr/share/hard-gaming-os/target-payload/$EDITION/"
install -m 0755 "$ROOT/installer/hgos-target-hook.sh" "$OUT/usr/local/libexec/hgos-target-hook"
install -m 0755 "$ROOT/scripts/audit-target-packages.py" "$OUT/usr/local/libexec/hgos-audit-target-packages"
install -m 0644 "$ROOT/config/editions/$EDITION.packages" "$OUT/usr/share/hard-gaming-os/manifests/$EDITION.packages"
# Calamares shellprocess-Konfiguration muss im konkreten Upstream überprüft werden.
cat > "$OUT/integration/shellprocess-hgos.conf" <<EOF
---
# Vorlage für ein Calamares shellprocess-Modul NACH der Rootfs-Installation.
# Nur mit geprüftem Upstream-Sequence-Eintrag aktivieren.
dontChroot: true
script:
  - "/usr/local/libexec/hgos-target-hook $EDITION @@ROOT@@"
EOF
cat > "$OUT/integration/README.txt" <<EOF
ACHTUNG: Die Konfiguration ist eine Integrationsvorlage, nicht aktiv!
@@ROOT@@ ist ein absichtlicher Platzhalter, kein echtes Calamares-Ziel.
Vor Aktivierung: Calamares-Sequence, Shellprocess-Syntax und Zielroot-Variable
am fixierten CachyOS-Commit prüfen. Keine Online-Installationsgarantie.
EOF
printf 'Calamares-Vorlage: %s\n' "$OUT"
