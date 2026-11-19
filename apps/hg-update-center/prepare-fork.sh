#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEST="${HGOS_UPDATER_WORKDIR:-$ROOT/build/hg-update-center/upstream}"
if [[ -e "$DEST" ]]; then echo "Abbruch: Ziel existiert bereits: $DEST" >&2; exit 2; fi
command -v git >/dev/null || { echo "git fehlt" >&2; exit 2; }
mkdir -p "$(dirname "$DEST")"
git init -q "$DEST"
git -C "$DEST" fetch --depth 1 https://github.com/akanbaz/cachy-updater.git 3011d681a65f2bb8d3193f39c384bdf75094db2b
git -C "$DEST" checkout --detach FETCH_HEAD
git -C "$DEST" rev-parse HEAD > "$(dirname "$DEST")/UPSTREAM_COMMIT"
python3 "$ROOT/apps/hg-update-center/brand-fork.py" "$DEST" "$ROOT/assets/HG OS.png"
echo "Quellcode vorbereitet: $DEST"
