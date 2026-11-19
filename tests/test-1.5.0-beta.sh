#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for edition in gaming allround; do
  python3 "$ROOT/scripts/plan-target-packages.py" "$edition" --root "$ROOT"
  grep -q '^backend: pacman$' "$ROOT/build/$edition/calamares/integration/packages-hgos.conf"
  grep -q '^  - install:$' "$ROOT/build/$edition/calamares/integration/packages-hgos.conf"
done
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/config/editions"
printf 'bad package!\n' > "$TMP/config/editions/gaming.packages"
if python3 "$ROOT/scripts/plan-target-packages.py" gaming --root "$TMP" >/dev/null 2>&1; then
  echo 'ERROR: invalid package accepted' >&2; exit 1
fi
bash -n "$ROOT/installer/hgos-target-hook.sh"
python3 -m py_compile "$ROOT/scripts/plan-target-packages.py"
echo 'PASS: package plans and invalid-name rejection'
