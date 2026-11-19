#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
for EDITION in gaming allround; do
 bash "$ROOT/scripts/prepare-calamares.sh" "$EDITION" >/dev/null
 STAGE="$ROOT/build/$EDITION/calamares/usr"
 test -x "$STAGE/local/libexec/hgos-audit-target-packages"
 test -f "$STAGE/share/hard-gaming-os/manifests/$EDITION.packages"
 cmp "$ROOT/config/editions/$EDITION.packages" "$STAGE/share/hard-gaming-os/manifests/$EDITION.packages"
 mkdir -p "$TMP/$EDITION/etc" "$TMP/$EDITION/usr" "$TMP/$EDITION/var/lib/pacman/local"
 while read -r NAME; do
  [[ -n "$NAME" && "$NAME" != \#* ]] || continue
  mkdir -p "$TMP/$EDITION/var/lib/pacman/local/$NAME-1"
  printf '%%NAME%%\n%s\n' "$NAME" > "$TMP/$EDITION/var/lib/pacman/local/$NAME-1/desc"
 done < "$ROOT/config/editions/$EDITION.packages"
 python3 "$ROOT/scripts/audit-target-packages.py" "$TMP/$EDITION" "$ROOT/config/editions/$EDITION.packages" >/dev/null
 FIRST="$(grep -v '^#' "$ROOT/config/editions/$EDITION.packages" | grep -v '^$' | head -1)"
 rm -rf "$TMP/$EDITION/var/lib/pacman/local/$FIRST-1"
 if python3 "$ROOT/scripts/audit-target-packages.py" "$TMP/$EDITION" "$ROOT/config/editions/$EDITION.packages" >/dev/null 2>&1; then
  echo 'Missing package not detected' >&2; exit 1
 fi
done
bash -n "$ROOT/installer/hgos-target-hook.sh" "$ROOT/scripts/prepare-calamares.sh" "$ROOT/scripts/integrate-calamares.sh"
echo 'OK: 1.4.0 manifest staging and audit for both editions'
