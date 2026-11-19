# Vollständiges Branding – 1.8.0 Beta

## Enthalten
- OS-Identität (`/etc/os-release`, `/etc/issue`)
- Hintergrundbilder und Logos
- Plymouth-Splash als Script-Theme (statisch)
- SDDM-Themenentwurf für Plasma (noch nicht live getestet)
- GRUB-Konfigurationsfragment (nur GRUB; systemd-boot und ISO-UEFI-Menüs separat)
- Vorhandenes Calamares-Branding aus 1.7.0

## Installation auf einem **Wegwerf-Testroot**
`sudo ./scripts/install-full-branding.sh --target /pfad/zum/testroot`

**Nicht direkt auf dem Buildhost ausführen.** Das Skript überschreibt im angegebenen Zielroot `/etc/os-release` und installiert Theme-Dateien. Für Live-ISO und installierte Systeme muss der Installer in die korrekte Rootfs-Buildphase eingebunden werden. `plymouth-set-default-theme`, initramfs-Neubau, GRUB-Neugenerierung und Login-Manager-Aktivierung sind noch nicht automatisiert. CachyOS kann einen anderen Login-Manager als SDDM nutzen; dann greift das SDDM-Theme nicht.

## Offene visuelle Bereiche
- ISO-Bootmenü für BIOS/UEFI, systemd-boot bzw. GRUB je nach Upstream-Profil
- Firmware/OEM-Logo und frühe Kernelmeldungen sind nicht generell umbrandbar
- CachyOS-Paketnamen, Repository-Adressen und technische Abhängigkeiten bleiben aus Kompatibilitätsgründen erhalten
- Branding im Calamares-Laufzeitpfad mit echtem Upstream testen
- SDDM-QML-Theme und Plymouth mit den tatsächlich installierten Versionen prüfen

**Keine Zusage eines zu 100 % markenfreien Starts, bevor alle Bootpfade in einer VM geprüft wurden.**
