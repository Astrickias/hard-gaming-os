# Hard Gaming Update Center

Seit 2.3.0 ein eigenes Paket: `packaging/hgos-update-center`.

- Basis: [cachy-updater](https://github.com/akanbaz/cachy-updater) von akanbaz, Commit `3011d681a65f2bb8d3193f39c384bdf75094db2b`, Lizenz GPL-3.0-or-later (bleibt erhalten, Lizenztext liegt im Paket unter `/usr/share/licenses/hgos-update-center/`).
- `brand-update-center.py` setzt Name, HG-Farben, HG-Logo und Tray-Symbole und übersetzt die wichtigsten Texte ins Deutsche. Passt eine Upstream-Stelle nicht mehr, bricht der Paketbau ab.
- Technische Kennungen bleiben upstream: Programm `cachyos-updater` (zusätzlich `hgos-update-center`), `org.cachyos.updater`-Dateien, Polkit-Regel, systemd-User-Units.
- Das Taskleistensymbol startet für alle Benutzer (`systemctl --global enable org.cachyos.updater-tray.service`).
- Grafiken in `packaging/hgos-update-center/assets/` sind SVG-Hüllen mit eingebettetem PNG aus `assets/HG OS.png` und `hg-tray*.png`.

Noch englisch: einzelne Knöpfe und Meldungen in Updates, Aufräumen, Firmware und Verlauf.
