#!/usr/bin/env bash
# Installiert nur das HGOS-Branding in ein bereits vorhandenes Zielroot.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
usage() { echo "Aufruf: $0 gaming --target /pfad/zum/mountpoint" >&2; exit 2; }
[[ $# == 3 && "$2" == --target ]] || usage
EDITION="$1"; TARGET="$3"
[[ "$EDITION" == gaming ]] || usage
[[ -d "$TARGET" && ! -L "$TARGET" ]] || { echo "Zielroot fehlt oder ist ein Symlink" >&2; exit 3; }
TARGET="$(realpath -e -- "$TARGET")"
[[ "$TARGET" != / && "$TARGET" != "$ROOT" && "$TARGET" != "$ROOT"/* ]] || { echo "Unsicheres Zielroot" >&2; exit 3; }
[[ -d "$TARGET/etc" && -d "$TARGET/usr" ]] || { echo "Kein erkennbares installiertes Linux-Zielroot" >&2; exit 3; }
"$ROOT/scripts/prepare-edition.sh" "$EDITION" --output "$ROOT/build/$EDITION"
OVERLAY="$ROOT/build/$EDITION/overlay"
# Bestehende Dateien werden nicht überschrieben: Upstream-Konfiguration bleibt erhalten.
while IFS= read -r -d '' FILE; do
  REL="${FILE#"$OVERLAY"/}"
  DEST="$TARGET/$REL"
  if [[ -e "$DEST" || -L "$DEST" ]]; then
    if cmp -s -- "$FILE" "$DEST"; then continue; fi
    echo "Konflikt: $REL – nicht überschrieben" >&2
    exit 4
  fi
done < <(find "$OVERLAY" -type f -print0)
cp -an -- "$OVERLAY/." "$TARGET/"
printf 'Hard Gaming OS %s (%s)\n' '0.8.0-alpha' "$EDITION"

