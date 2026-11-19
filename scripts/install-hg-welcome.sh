#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"
if [[ -z "$TARGET" || "$TARGET" != /* || "$TARGET" == / || ! -d "$TARGET" ]]; then echo "Usage: $0 /absolute/test-or-staging-root (not /)" >&2; exit 2; fi
install -d "$TARGET/usr/share/hard-gaming-os/welcome" "$TARGET/usr/share/applications" "$TARGET/etc/xdg/autostart"
cp -a "$ROOT/apps/hg-welcome/." "$TARGET/usr/share/hard-gaming-os/welcome/"
cat > "$TARGET/usr/share/applications/hg-welcome.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Hello Hard Gaming OS
Comment=Willkommen bei Hard Gaming OS
Exec=xdg-open /usr/share/hard-gaming-os/welcome/index.html
Icon=help-about
Terminal=false
Categories=System;Utility;
EOF
cat > "$TARGET/etc/xdg/autostart/hg-welcome.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Hello Hard Gaming OS
Exec=sh -c 'test -e "$HOME/.config/hg-welcome/skip-autostart" || xdg-open /usr/share/hard-gaming-os/welcome/index.html'
OnlyShowIn=KDE;
X-KDE-autostart-phase=2
EOF
echo "Hard Gaming Welcome staged in $TARGET"
