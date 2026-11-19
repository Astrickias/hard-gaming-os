#!/usr/bin/env bash
# Conservative integration into a prepared CachyOS live root. Does not run installer.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EDITION="${1:-}"; LIVE="${2:-}"
[[ "$EDITION" == gaming || "$EDITION" == allround ]] || { echo 'Edition gaming|allround erforderlich' >&2; exit 2; }
[[ -n "$LIVE" && -d "$LIVE/etc" && -d "$LIVE/usr" ]] || { echo 'LIVE-ROOT ungültig' >&2; exit 2; }
LIVE="$(realpath -e -- "$LIVE")"
[[ "$LIVE" != / ]] || exit 2
# Do not touch upstream settings unless a known Calamares layout is present.
SETTINGS="$LIVE/usr/share/calamares/settings_online.conf"
[[ -f "$SETTINGS" ]] || { echo 'CachyOS settings_online.conf fehlt' >&2; exit 3; }
[[ ! -e "$LIVE/etc/calamares/modules/shellprocess_hgos.conf" ]] || { echo 'HGOS Modul existiert bereits' >&2; exit 3; }
[[ ! -e "$LIVE/usr/local/libexec/hgos-target-hook" ]] || { echo 'HGOS Hook existiert bereits' >&2; exit 3; }
# Preserve original sequence, append only after all normal execution steps and before umount.
python3 - "$SETTINGS" <<'PYCODE'
import sys
from pathlib import Path
p=Path(sys.argv[1]); s=p.read_text()
if 'shellprocess@hgos' in s or '- umount' not in s or 'branding:' not in s:
    raise SystemExit('Unbekannte/inkompatible Calamares-Konfiguration')
if '  - umount' not in s:
    raise SystemExit('Kein eindeutiger umount-Schritt')
PYCODE
"$ROOT/scripts/prepare-edition.sh" "$EDITION" >/dev/null
mkdir -p "$LIVE/usr/share/hard-gaming-os/target-payload/$EDITION" "$LIVE/usr/local/libexec" "$LIVE/usr/share/hard-gaming-os/manifests" "$LIVE/etc/calamares/modules"
cp -a "$ROOT/build/$EDITION/overlay/." "$LIVE/usr/share/hard-gaming-os/target-payload/$EDITION/"
install -m 0755 "$ROOT/installer/hgos-target-hook.sh" "$LIVE/usr/local/libexec/hgos-target-hook"
install -m 0755 "$ROOT/scripts/audit-target-packages.py" "$LIVE/usr/local/libexec/hgos-audit-target-packages"
install -m 0644 "$ROOT/config/editions/$EDITION.packages" "$LIVE/usr/share/hard-gaming-os/manifests/$EDITION.packages"
# Calamares shellprocess expands @@ROOT@@ to the mounted installation root.
cat > "$LIVE/etc/calamares/modules/shellprocess_hgos.conf" <<EOF
---
dontChroot: true
script:
  - "/usr/local/libexec/hgos-target-hook $EDITION @@ROOT@@"
EOF
# Patch ONLY the live-root's online settings; never touch user's actual /etc.
python3 - "$SETTINGS" <<'PYCODE'
import sys
from pathlib import Path
p=Path(sys.argv[1]); s=p.read_text()
needle='  - umount'
s=s.replace(needle,'  - shellprocess@hgos\n'+needle,1)
anchor='instances:'
if anchor not in s: raise SystemExit('instances fehlt')
s=s.replace(anchor,anchor+'\n  - id: hgos\n    module: shellprocess\n    config: shellprocess_hgos.conf',1)
p.write_text(s)
PYCODE
"$ROOT/scripts/install-calamares-branding.sh" "$LIVE"
echo "HGOS Calamares Online-Hook und Branding vorbereitet: $EDITION"
