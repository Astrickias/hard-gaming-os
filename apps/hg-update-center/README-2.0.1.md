# Hard Gaming Update Center – 2.0.1 Beta

Der Qt-Updater wurde auf dem CachyOS-PC des Testers erfolgreich kompiliert und geöffnet. Branding und Navigation sind **noch nicht verifiziert**.

## Test

```bash
cd ~/Hard-Gaming-OS
bash apps/hg-update-center/test-and-audit.sh
```

Das Skript zeigt verbleibende CachyOS-Nennungen in QML, Logo-Dateien und Desktop-Dateien, speichert den Bericht unter `build/hg-update-center/branding-audit.txt` und startet den lokal gebauten Updater **ohne root**. Es führt keine Updates aus und verändert keine Upstream-Dateien.

**Wichtig:** Für die nächste konkrete QML-Änderung bitte den Audit-Bericht und einen Screenshot der geöffneten Anwendung bereitstellen. Upstream-Programmkennung, Update-Logik und Links nicht blind ersetzen.
