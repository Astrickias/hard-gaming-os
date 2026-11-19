#!/usr/bin/env bash
# Startet den Hard-Gaming-OS-Installer und zeigt bei einem Fehler den Grund an,
# statt dass sich das Fenster kommentarlos schließt.
LOG="$HOME/hgos-installer-start.log"
if [[ ! -x /usr/local/bin/calamares-online.sh ]]; then
  MSG="Hard Gaming OS ist bereits installiert. Der Installer ist nur im Live-System verfügbar."
  command -v kdialog >/dev/null && exec kdialog --title "Hard Gaming OS" --msgbox "$MSG"
  exec notify-send "Hard Gaming OS" "$MSG"
fi
/usr/local/bin/calamares-online.sh >"$LOG" 2>&1 && exit 0
TAIL="$(grep -E 'HGOS|error|Fehler' "$LOG" | tail -n 8)"
MSG="Der Installer konnte nicht starten.

${TAIL:-Keine Details.}

Vollständiges Protokoll: $LOG"
if command -v kdialog >/dev/null; then
  kdialog --title "Hard Gaming OS installieren" --error "$MSG"
else
  konsole --hold -e tail -n 60 "$LOG"
fi
exit 1
