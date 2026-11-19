# Hard Gaming Welcome 1.9.0 Beta

Lokale HTML/CSS-Willkommensoberfläche ohne JavaScript, Telemetrie oder Remote-Code. Originalgrafiken aus `assets/` werden unverändert kopiert.

## Test

`python3 -m http.server 8765 --directory apps/hg-welcome` und `http://localhost:8765` öffnen. Für die lokale Vorschau ist keine Installation erforderlich.

## Staging

`./scripts/install-hg-welcome.sh /absoluter/pfad/zu/einem/testroot`

**Nicht** gegen `/` ausführen. Die Integration in CachyOS-Live-Rootfs und Calamares-Zielsystem ist noch nicht automatisch verdrahtet. Der Autostart ist eine Vorlage für die spätere ISO-Integration. Er lässt sich pro Benutzer mit `~/.config/hg-welcome/skip-autostart` unterdrücken.

## ArtCraft

Nur Verlinkung auf `https://github.com/storytold/craft-launcher/releases`, keine ungeprüften Binärdateien oder automatischen Installationen. ArtCraft und seine Marken bleiben dem jeweiligen Rechteinhaber zugeordnet. Auf Arch/CachyOS geeignete Releaseformate vor dem Paketieren prüfen.

## Lizenz

Dieses Welcome ist eine eigenständige Implementierung, kein Fork von CachyOS Hello. Vor Wiederverwendung von CachyOS-Hello-Code ist dessen Lizenz zu prüfen. Die CachyOS-Basis und die Herkunft werden in der technischen Dokumentation transparent genannt.
