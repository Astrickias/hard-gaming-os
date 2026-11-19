# Hard Gaming OS 1.3.0 Beta – Änderungsliste

- Read-only Audit der tatsächlich installierten Editionspakete anhand der Pacman-Datenbank des Zielsystems.
- Fehlende Editionspakete werden mit Fehlerstatus ausgegeben, nicht stillschweigend als installiert betrachtet.
- Build-Staging enthält nun das Editions-Paketmanifest unter `/usr/share/hard-gaming-os/edition-packages.txt`.
- Calamares-Vorlage verwendet `@@ROOT@@` statt des nicht existierenden Testverzeichnisses.
- Veraltete fest codierte Versionsangabe aus dem Branding-Hook entfernt.
- Regressionstests für Paket-Audit, fehlende Pakete und Zielroot-Schutz ergänzt.

**Offen:** Die Paketinstallation selbst ist weiterhin nicht nachgewiesen. Calamares-Hook und ISO-Boot benötigen Tests mit fixiertem CachyOS-Upstream und VM.
