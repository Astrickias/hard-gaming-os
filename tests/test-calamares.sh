#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
for EDITION in gaming allround; do
 "$ROOT/scripts/prepare-calamares.sh" "$EDITION" >/dev/null
 mkdir -p "$TMP/root/etc" "$TMP/root/usr" "$TMP/live/usr/share/hard-gaming-os/target-payload"
 cp -a "$ROOT/build/$EDITION/calamares/usr/share/hard-gaming-os/target-payload/$EDITION" "$TMP/live/usr/share/hard-gaming-os/target-payload/"
 # Test the hook in an isolated fake live-root by replacing its absolute payload path.
 sed "s|^PAYLOAD=.*|PAYLOAD=\"$TMP/live/usr/share/hard-gaming-os/target-payload/\$EDITION\"|" "$ROOT/installer/hgos-target-hook.sh" > "$TMP/hook.sh"
 bash "$TMP/hook.sh" "$EDITION" "$TMP/root" >/dev/null
 [[ "$(cat "$TMP/root/usr/share/hard-gaming-os/edition")" == "$EDITION" ]]
 bash "$TMP/hook.sh" "$EDITION" "$TMP/root" >/dev/null
 if bash "$TMP/hook.sh" invalid "$TMP/root" >/dev/null 2>&1; then exit 1; fi
 if bash "$TMP/hook.sh" "$EDITION" / >/dev/null 2>&1; then exit 1; fi
 rm -rf "$TMP/root" "$TMP/live"
done
echo 'PASS: beide Editionen, idempotente Installation, ungültige Edition und Root-Schutz'
