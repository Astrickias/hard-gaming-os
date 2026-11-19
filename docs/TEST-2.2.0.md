# Testberichte 2.1.4 / 2.1.6 und Prüfliste 2.2.0

## Ergebnis 2.1.4 Gaming (19.11.2026, virt-manager, QEMU/KVM, UEFI)

Getestet von Dominik, Screenshots sind echte VM-Screenshots.

| Schritt | Ergebnis |
|---|---|
| ISO-Build | ISO entstanden (3,6 GB). `buildiso.sh` meldete danach „Aborted by user“, deshalb kein automatisches Kopieren nach `dist/iso/`. |
| Live-Start bis KDE | ✅ Der dunkle Bildschirm aus 2.1.3 ist behoben. |
| Hello | ✅ öffnet sich, beide Links vorhanden. Zusätzlich Firefox-Datenschutz-Tab. |
| Installer | ❌ ohne Eingriff: `libboost_python314.so.1.91.0` fehlt (cachyos-calamares-next 3.4.2-13 gegen Boost 1.91 gebaut, Repo hat 1.92). ✅ mit boost-libs 1.91 aus dem Arch-Archiv. |
| Installation | ✅ |
| Neustart ohne ISO | ✅ |
| Edition/Pakete | ✅ `gaming`, steam, lutris, heroic-games-launcher, mangohud, gamemode |
| Branding | ❌ CachyOS-GRUB-Theme, -Plymouth, Iridescent-KDE, fastfetch-Logo, lsb-release, Hostname-Vorschlag, Bootloader-Bilder, Calamares-Seitenleiste unlesbar, KDE-Standardwallpaper |
| Legacy-BIOS | nicht getestet |

## Was 2.1.5 und 2.1.6 dagegen tun

| Befund | Änderung |
|---|---|
| Boost-Fehler | `hgos-calamares-libfix` prüft vor dem Start mit `ldd`. Fehlt nur Boost, holt es genau die passende `boost-libs`-Version aus dem Arch-Archiv, nur ins Live-System. |
| Installer schließt sich still | `hgos-install` zeigt bei einem Fehler eine Meldung mit Logauszug. |
| ISO nicht kopiert | `build-cachyos.sh` wertet die neue ISO aus statt des Exit-Codes von `buildiso.sh`. |
| CachyOS-Grafik im Zielsystem | Paket `hgos-branding` ersetzt per `provides/conflicts` `cachyos-grub-theme`, `cachyos-plymouth-theme`, `cachyos-plymouth-bootanimation`, `cachyos-iridescent-kde`. Updates holen sie nicht zurück. |
| CachyOS-Programme | `cachyos-hello`, `-kernel-manager`, `-packageinstaller`, `-wallpapers`, `-kde-settings` werden entfernt. |
| GRUB | HG-Theme, `GRUB_DISTRIBUTOR="Hard Gaming OS"`, Snapshot-Menü „Hard Gaming OS Snapshots“, `grub-mkconfig` nach der Installation |
| Plymouth | HG-Theme als Standard, `mkinitcpio -P` nach der Installation |
| Systemkennung | `/etc/os-release`, `/etc/lsb-release`, `/etc/issue`. Ein pacman-Hook stellt sie nach Updates wieder her. |
| fastfetch | HG-Logo über `/etc/xdg/fastfetch/config.jsonc` |
| Desktop | Plasma-Design „Hard Gaming“, Farbschema „Hard Gaming“, Wallpaper „Hard Gaming OS“ als Standard und in der Auswahl |
| Calamares | Seitenleiste lesbar, Hostname `hardgaming-…`, HG-Bilder auf der Bootloader-Seite, Diashow ohne doppeltes Logo |
| Hello | eigenes Firefox-Fenster ohne Datenschutz-Tab, Karten „Installieren“, „System aktualisieren“, „Hard Gaming CMS“, „Machi“, Hinweis auf CachyOS und Arch Linux |

Bewusst unverändert: Kernel `linux-cachyos`, Repos, Mirrorlisten, Schlüssel, `pacman.conf`, `cachyos-settings`, `cachyos-hooks`, `cachyos-ananicy-rules`, `cachyos-snapper-support`, fish/zsh-Grundkonfiguration, `ID_LIKE="cachyos arch"` in os-release.

## Prüfliste 2.2.0 (eine Edition)

1. Build: `sudo env HGOS_UPSTREAM_REF=3215497d2e8c5fea90e185affcf973dfa2cf790b HGOS_ACK_EXPERIMENTAL=1 HGOS_ACK_TARGET_UNVERIFIED=1 ./scripts/build-release.sh`. Erwartet: `dist/iso/Hard-Gaming-OS-2.2.0-beta-x86_64.iso` und `.sha256`.
2. Live: Bootmenü, Plymouth-Logo, KDE mit HG-Wallpaper und grünem Farbschema, Hello im eigenen Fenster ohne Datenschutz-Tab.
3. Hello → „Installer starten“. Calamares öffnet sich ohne Handarbeit. Seitenleiste lesbar, Hostname `hardgaming-…`, Bootloader-Bild HG.
4. Installation mit GRUB, „Festplatte löschen“. In der Paketauswahl ist „Office & Alltag“ angehakt.
5. Neustart ohne ISO: HG-GRUB-Theme, HG-Plymouth, Login, Desktop mit HG-Wallpaper, Hello.
6. Konsole im installierten System:
   ```
   pacman -Q hgos-branding
   cat /etc/lsb-release
   pacman -Qq | grep -i cachy
   cat /var/log/hard-gaming-os-install.log
   pacman -Q steam lutris heroic-games-launcher kate ark libreoffice-fresh-de
   ```
   Erwartet: Keine der vier ersetzten Grafikpakete und keine CachyOS-Programme mehr in der Liste.
7. `sudo pacman -Syu` ausführen, danach `cat /etc/os-release` und `grep DISTRIBUTOR /etc/default/grub`: weiterhin Hard Gaming OS.
8. Optional: Legacy-BIOS-VM mit denselben Schritten.

## Build-Abbruch 2.1.5 (19.11.2026)

`customize_airootfs.sh` brach beim Installieren von `hgos-branding` ab: Im mkarchiso-Chroot gibt es noch keinen Paket-Schlüsselbund, und `pacman -U` prüft auch bei einem lokalen Paket die Signaturen der Online-Datenbanken (`database 'cachyos' is not valid`). 2.1.6 installiert das Paket mit `pacman-local.conf` ohne Online-Repos, im Live-System und im Zielsystem.

## Ergebnis 2.1.6 Gaming (19.11.2026, virt-manager, QEMU/KVM, UEFI)

Getestet von Dominik, echte VM-Screenshots.

| Schritt | Ergebnis |
|---|---|
| ISO-Build mit Prüfsumme | ✅ `023db103ae46ed067bd430b1814aceddbf3d2014916114d2ee8d38a5580ee3a6` |
| Live-System mit HG-Design, Hello im eigenen Fenster | ✅ |
| Installer direkt aus Hello, Seitenleiste lesbar, Diashow | ✅ |
| Installation, Neustart ohne ISO | ✅ |
| GRUB-Menü und Startbild | ✅ |
| Wallpaper, Farbschema, fastfetch, Hostname `hardgaming-x8664` | ✅ |
| `hgos-branding 2.1.6-1`, CachyOS-Grafikpakete entfernt | ✅ |
| Verbleibende cachyos-Pakete | nur technisch: Kernel, Keyring, Mirrorlisten, settings, hooks, ananicy-rules, drm-awaiter, snapper-support, fish/zsh-config |
| Legacy-BIOS | nicht getestet |

Offen aus dem Test: fastfetch-Logo türkis statt HG-Grün (in 2.2.0 auf RGB 84,239,97 gestellt). Der Tooltip „Application Launcher“ ist englisch; das ist ein fehlender KDE-Übersetzungstext, kein CachyOS-Branding.

## 2.2.0: eine Edition

Gaming und Allround sind zusammengelegt. Fest installiert: Steam, Lutris, Heroic, MangoHud, GameMode, Kate, Ark, Firefox. LibreOffice (deutsch) ist im Installer als Gruppe „Office & Alltag“ wählbar und standardmäßig angehakt. Intern heißt die Edition weiterhin `gaming`, sichtbar überall nur „Hard Gaming OS“.
