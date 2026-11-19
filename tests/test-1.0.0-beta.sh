#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for edition in gaming allround; do
  tmp="$(mktemp -d)"
  mkdir -p "$tmp/etc" "$tmp/usr/share/calamares" "$tmp/usr"
  cat > "$tmp/usr/share/calamares/settings_online.conf" <<'EOF'
---
instances:
  - id: online
    module: packages
    config: packages_online.conf
sequence:
  - exec:
  - partition
  - bootloader
  - umount
branding: cachyos
EOF
  "$ROOT/scripts/integrate-calamares.sh" "$edition" "$tmp" >/dev/null
  grep -q 'shellprocess@hgos' "$tmp/usr/share/calamares/settings_online.conf"
  grep -q 'branding: hardgamingos' "$tmp/usr/share/calamares/settings_online.conf"
  grep -q "$edition @@ROOT@@" "$tmp/etc/calamares/modules/shellprocess_hgos.conf"
  test -f "$tmp/usr/share/hard-gaming-os/target-payload/$edition/etc/hard-gaming-os-release" || find "$tmp/usr/share/hard-gaming-os/target-payload/$edition" -type f | grep -q .
  if "$ROOT/scripts/integrate-calamares.sh" "$edition" "$tmp" >/dev/null 2>&1; then echo 'Doppelintegration nicht abgewehrt' >&2; exit 1; fi
  rm -rf "$tmp"
done
echo 'Fixture-Tests beider Editionen bestanden'
