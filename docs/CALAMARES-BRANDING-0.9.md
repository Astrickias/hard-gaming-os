# Calamares-Branding 0.9.0 Alpha

Die Branding-Dateien befinden sich unter `installer/calamares/branding/hardgamingos`.

## Installation in ein vorbereitetes Live-Root

`sudo scripts/install-calamares-branding.sh /pfad/zum/live-root`

Das Skript passt nur bestehende `branding: cachyos`-Einträge an und belässt die Calamares-Installationssequenz unverändert. Wichtig: Das CachyOS-Online-Startskript kopiert `settings_online.conf` in die aktive Konfiguration; daher werden beide Stellen berücksichtigt.

## Offene Integrationsarbeiten

- Die tatsächliche Calamares-Version muss das QML-Slideshow-Format und alle `branding.desc`-Schlüssel akzeptieren.
- Edition-spezifische Zielpakete und der Zielsystem-Hook sind **nicht** automatisch in Calamares aktiviert.
- Ein echtes CachyOS-ISO, Boot- und Installationstest sind noch erforderlich.
- Keine eigenen Websites oder Support-URLs eingetragen, solange sie nicht bekannt sind.
