#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for f in "$ROOT"/scripts/*.sh "$ROOT"/installer/*.sh; do bash -n "$f"; done
python3 -m py_compile "$ROOT/scripts/hgos-calamares-runtime.py" "$ROOT/scripts/install-runtime-wrapper.py"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/settings.conf" <<'EOF'
---
instances:
  - id: online
    module: packages
sequence:
  - exec:
  - partition
  - umount
branding: cachyos
EOF
python3 "$ROOT/scripts/hgos-calamares-runtime.py" "$TMP/settings.conf"
grep -q 'shellprocess@hgos' "$TMP/settings.conf"
grep -q 'branding: hardgamingos' "$TMP/settings.conf"
if python3 "$ROOT/scripts/hgos-calamares-runtime.py" "$TMP/settings.conf" 2>/dev/null; then exit 1; fi
cat > "$TMP/calamares-online.sh" <<'EOF'
#!/bin/bash
sudo cp "/usr/share/calamares/settings_${mode}.conf" /etc/calamares/settings.conf
exec pkexec-wrapper calamares -D6 >> $log
EOF
python3 "$ROOT/scripts/install-runtime-wrapper.py" "$TMP/calamares-online.sh"
grep -q 'hgos-calamares-runtime' "$TMP/calamares-online.sh"
for edition in gaming allround; do
  bash "$ROOT/scripts/prepare-edition.sh" "$edition" >/dev/null
  test -s "$ROOT/build/$edition/packages.txt"
done
echo 'OK: Runtime-Integration, Editionen, Shell-Syntax und Negativtests'
