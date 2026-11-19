# Calamares-Integration – 0.7.0 Alpha

Die Zielsystem-Branding-Routine `scripts/apply-target-branding.sh` ist implementiert und kann mit einem gemounteten Test-Zielroot aufgerufen werden.

**Noch keine automatische Calamares-Anbindung:** CachyOS liefert seine Installer-Konfiguration als separate Pakete und verwendet Online-/Offline-Pfade. Vor der Integration müssen die konkreten Module, Hook-Reihenfolge, Mountpoints und Installationswege an einem festgelegten CachyOS-Commit geprüft werden. Es wird bewusst keine unbestätigte `shellprocess`-Konfiguration in das ISO injiziert.

`sudo ./scripts/apply-target-branding.sh gaming --target /mnt/test-install`

Die Routine installiert Branding und KDE-Vorlagen, keine Editionspakete. Bei Dateikonflikten bricht sie ab, ohne bestehende Dateien zu überschreiben. Für echte Zielsystem-Tests nur nach erfolgreicher Installation und mit geprüftem Mountpoint ausführen.

Bekannte offene Punkte: Installer-Hook, Paketinstallation im Zielroot, Branding der Installer-Oberfläche, ISO- und UEFI-Boot-Test.
