# ISO-Build und VM-Test

Der Build nutzt das Desktop-Profil von [CachyOS-Live-ISO](https://github.com/CachyOS/CachyOS-Live-ISO) am Commit `3215497d2e8c5fea90e185affcf973dfa2cf790b`. Die Calamares-Anpassung wurde gegen die Quellkonfiguration am Commit `1f939ebed330ea2c86f27b90a85d22c01c7571b5` geprüft. Der Online-Installer lädt Calamares und Zielpakete zur Laufzeit aus den CachyOS-Repositories. Paketverfügbarkeit und die ausgelieferte Calamares-Version sind dadurch Teil des VM-Tests.

## Auf einer separaten CachyOS-VM

In einem Projektpfad ohne Leerzeichen arbeiten. Der Upstream-Build kann das installierte `mkarchiso` ändern. Die folgenden Builds nacheinander starten.

```bash
sudo pacman -Syu --needed archiso mkinitcpio-archiso git squashfs-tools grub python gettext base-devel cmake ninja kirigami qqc2-desktop-style pacman-contrib expac
./scripts/preflight.sh
./scripts/test-integration.sh
./scripts/build-cachyos.sh
sudo env HGOS_UPSTREAM_REF=3215497d2e8c5fea90e185affcf973dfa2cf790b \
  HGOS_ACK_EXPERIMENTAL=1 HGOS_ACK_TARGET_UNVERIFIED=1 \
  ./scripts/build-release.sh
```

Erwartete Ausgabe ist eine ISO-Datei samt SHA-256 unter `dist/iso/` und Buildprotokolle unter `dist/logs/`.

## Abnahme

Ablauf, Bootlog-Auswertung und Screenshots: [DIAGNOSE-2.1.4.md](DIAGNOSE-2.1.4.md) mit `scripts/vm-test.sh`. Prüfliste für 2.4.0: [TEST-2.4.0.md](TEST-2.4.0.md).

Der Build startet per `sudo` von einem normalen Benutzer: `makepkg` baut die Pakete `hgos-branding` und `hgos-update-center` als dieser Benutzer. Für das Update Center lädt `makepkg` den Quellcode von GitHub.

1. Jede ISO mit UEFI und Legacy-BIOS in einer VM starten. Die virtuelle Zielplatte soll leer sein.
2. Über „Hard Gaming OS installieren“ Calamares starten. Branding, Partitionierung und die Installation bis zum Abschluss prüfen.
3. Die ISO auswerfen und von der virtuellen Platte starten. Anmeldung und Hello Hard Gaming OS samt Website-Link prüfen. Editionskennung unter `/usr/share/hard-gaming-os/edition` und Editionspakete mit `pacman -Q` prüfen.
4. Bootmenü (GRUB und Syslinux), Plymouth, Systeminfo, Plasma-Anmeldung und Standard-Wallpaper in Live- und Zielsystem abnehmen. Die Live-Sitzung verwendet automatische Anmeldung. Den Greeter dort durch Abmelden sichtbar machen.
5. In Plasma den Hintergrund ändern und erneut anmelden. Der Branding-Starter soll den gewählten Hintergrund nach der ersten Einrichtung beibehalten.

Das Profil verändert sichtbare Branding-Dateien. Die CachyOS-Repositories, Schlüssel, Kernelnamen und Upstream-Quellen bleiben Teil der technischen Basis. Das Hard Gaming Update Center baut `scripts/build-packages.sh` aus `packaging/hgos-update-center` (Fork von cachy-updater auf festem Commit) und installiert es bei der Installation ins Zielsystem. Craft Apps sind im Welcome verlinkt.
