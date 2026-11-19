# CachyOS ISO-Build 0.6.0 Alpha

Auf einem CachyOS/Arch-basierten Buildhost: `sudo pacman -S --needed git archiso mkinitcpio-archiso squashfs-tools grub`.

Vorbereitung: `./scripts/build-cachyos.sh gaming` und `./scripts/build-cachyos.sh allround`.

Experimenteller Build: `sudo HGOS_ACK_EXPERIMENTAL=1 ./scripts/build-cachyos.sh gaming --execute` (analog allround).

Das Skript klont das offizielle CachyOS-Live-ISO-Repository, kopiert einen Git-Snapshot in ein isoliertes Staging-Verzeichnis, ergänzt die Live-Overlay-Dateien und startet bei Freigabe das native `buildiso.sh -p desktop -v -w`.

**Wichtige Grenzen:** Kein CachyOS-Build auf diesem Entwicklungsrechner ausgeführt. Es ist nicht verifiziert, ob die aktuelle Upstream-Buildpipeline die im Profil ergänzten Dateien und Pakete vollständig übernimmt. Calamares installiert die Edition-Pakete und das HG-Branding im Zielsystem noch nicht nachweislich. Für eine Veröffentlichung müssen die Online-/Offline-Installerpfade, Zielsystempakete, Bootfähigkeit, Lizenzhinweise und Hardwaretests separat geprüft werden. Insbesondere Gaming-Pakete sind vor einem Build gegen die aktiven Paketquellen zu validieren.

Quellen: https://github.com/CachyOS/CachyOS-Live-ISO und https://github.com/CachyOS/cachyos-calamares
