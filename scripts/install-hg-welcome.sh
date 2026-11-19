#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"
if [[ -z "$TARGET" || "$TARGET" != /* || "$TARGET" == / || ! -d "$TARGET" ]]; then echo "Usage: $0 /absolute/test-or-staging-root (not /)" >&2; exit 2; fi
install -d "$TARGET/usr/share/hard-gaming-os/welcome" "$TARGET/usr/share/applications" "$TARGET/etc/xdg/autostart"
cp -a "$ROOT/apps/hg-welcome/." "$TARGET/usr/share/hard-gaming-os/welcome/"
install -Dm755 "$ROOT/apps/hg-welcome/hg-welcome" "$TARGET/usr/local/bin/hg-welcome"
install -Dm755 "$ROOT/apps/hg-welcome/hgos-url" "$TARGET/usr/local/bin/hgos-url"
rm -f "$TARGET/usr/share/hard-gaming-os/welcome/hg-welcome" "$TARGET/usr/share/hard-gaming-os/welcome/hgos-url"
cat > "$TARGET/usr/share/applications/hg-welcome.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Hello Hard Gaming OS
Comment=Willkommen bei Hard Gaming OS
Exec=/usr/local/bin/hg-welcome
Icon=/usr/share/hard-gaming-os/hg-os-logo.png
Terminal=false
Categories=System;Utility;
DESKTOP
cat > "$TARGET/etc/xdg/autostart/hg-welcome.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Hello Hard Gaming OS
Exec=sh -c 'grep -qs "^showOnStartup=false" "$HOME/.config/hg-welcome.conf" || exec /usr/local/bin/hg-welcome'
OnlyShowIn=KDE;
X-KDE-autostart-phase=2
DESKTOP
# hgos://install und hgos://update aus Hello heraus.
cat > "$TARGET/usr/share/applications/hgos-url.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Hard Gaming OS Aktionen
Exec=/usr/local/bin/hgos-url %u
MimeType=x-scheme-handler/hgos;
NoDisplay=true
Terminal=false
DESKTOP
# Firefox: kein Erststart-/Datenschutz-Tab vor Hello, Startseite hardgaming.net,
# hgos://-Links ohne Rückfrage an das System weitergeben.
install -Dm644 /dev/stdin "$TARGET/etc/firefox/policies/policies.json" <<'JSON'
{
  "policies": {
    "OverrideFirstRunPage": "",
    "OverridePostUpdatePage": "",
    "DontCheckDefaultBrowser": true,
    "Homepage": { "URL": "https://hardgaming.net/", "StartPage": "homepage" },
    "Preferences": {
      "datareporting.policy.dataSubmissionPolicyBypassNotification": { "Value": true, "Status": "default" }
    },
    "Handlers": {
      "schemes": { "hgos": { "action": "useSystemDefault", "ask": false } }
    }
  }
}
JSON
echo "Hard Gaming Welcome staged in $TARGET"
