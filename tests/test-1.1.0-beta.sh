#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for edition in gaming allround; do
  temp="$(mktemp -d)"
  trap 'rm -rf "$temp"' EXIT
  mkdir -p "$temp/usr/share/calamares" "$temp/etc"
  cat > "$temp/usr/share/calamares/settings_online.conf" <<'EOF'
---
instances:
  - id: online
    module: packages
    config: packages_online.conf
sequence:
  - exec:
    - packages@online
    - bootloader
    - umount
branding: cachyos
EOF
  cat > "$temp/usr/share/calamares/settings_offline.conf" <<'EOF'
---
sequence:
  - exec:
    - unpackfs
    - umount
branding: cachyos
EOF
  bash "$ROOT/scripts/integrate-calamares.sh" "$edition" "$temp"
  python3 "$ROOT/scripts/audit-calamares.py" "$temp"
  if bash "$ROOT/scripts/integrate-calamares.sh" "$edition" "$temp" >/dev/null 2>&1; then echo 'Double integration accepted!' >&2;exit 1;fi
  rm -rf "$temp"
  trap - EXIT
done
bash -n "$ROOT/scripts/build-cachyos.sh" "$ROOT/scripts/integrate-calamares.sh" "$ROOT/installer/hgos-target-hook.sh"
echo 'HGOS 1.1.0 fixture tests PASS'
