#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EDITION="${1:-}"
[[ "$EDITION" == gaming ]] || { echo 'Usage: create-target-payload.sh gaming' >&2; exit 2; }
"$ROOT/scripts/prepare-edition.sh" "$EDITION"
mkdir -p "$ROOT/dist/payload"
# Data archive for controlled target-system integration; does not install packages.
tar -C "$ROOT/build/$EDITION/overlay" -czf "$ROOT/dist/payload/hgos-$EDITION-rootfs.tar.gz" .
cp "$ROOT/build/$EDITION/packages.txt" "$ROOT/dist/payload/hgos-$EDITION-packages.txt"
echo "Target payload prepared for $EDITION (not installed by Calamares yet)."
