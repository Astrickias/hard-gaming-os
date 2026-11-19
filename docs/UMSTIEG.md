# Umstieg von CachyOS auf Hard Gaming OS

Für bestehende **CachyOS-Installationen mit KDE Plasma**. Keine Neuinstallation, eigene Dateien und Programme bleiben. Nicht nötig auf einem bereits installierten Hard Gaming OS.

## Was das Paket macht

| Paket | Inhalt |
|---|---|
| `hgos-branding` | GRUB-Theme, Startbild (Plymouth), Plasma-Design „Hard Gaming“, Farbschema, Wallpaper, fastfetch-Logo. Ersetzt `cachyos-grub-theme`, `cachyos-plymouth-theme`, `cachyos-plymouth-bootanimation`, `cachyos-iridescent-kde`. Sichert beim ersten Anwenden `/etc/os-release`, `/etc/lsb-release`, `/etc/issue`, `/etc/default/grub` und die Plymouth-Einstellung unter `/var/lib/hard-gaming-os/backup`. |
| `hgos-update-center` | Hard Gaming Update Center mit Symbol in der Taskleiste. Ersetzt `cachyos-updater`, falls vorhanden. |
| `hgos-umstieg` | Systemname „Hard Gaming OS“, Logos, Hello Hard Gaming OS (startet beim nächsten Login) |

Unverändert bleiben Kernel, Paketquellen, Schlüssel, Treiber und `cachyos-settings`. Der Login-Bildschirm (SDDM bzw. Plasma Login) wird nicht verändert.

## Installation

Vorher ein Backup von `/home` anlegen. Empfohlen: zuerst in einer CachyOS-VM testen.

```bash
./scripts/build-umstieg.sh            # als normaler Benutzer, baut nach dist/packages/
sudo pacman -U dist/packages/hgos-keyring-*.pkg.tar.* \
               dist/packages/hgos-branding-*.pkg.tar.* \
               dist/packages/hgos-update-center-*.pkg.tar.* \
               dist/packages/hgos-umstieg-*.pkg.tar.*
```

pacman fragt, ob die CachyOS-Grafikpakete entfernt werden sollen: mit **j** bestätigen. Danach:

```bash
hgos-design-anwenden      # als normaler Benutzer
sudo mkinitcpio -P        # Startbild übernehmen
```

Abmelden und neu anmelden.

Einfacher über das Paket-Repo: siehe [PAKET-REPO.md](PAKET-REPO.md), Abschnitt „Umstieg über das Repo“. `hgos-keyring` ist seit 2.6.0 Voraussetzung und trägt das Repo `[hardgaming]` ein.

## Rückweg

```bash
hgos-design-zuruecksetzen
sudo pacman -Rns hgos-umstieg hgos-update-center hgos-branding hgos-keyring
sudo pacman -S cachyos-grub-theme cachyos-plymouth-bootanimation cachyos-iridescent-kde
sudo grub-mkconfig -o /boot/grub/grub.cfg && sudo mkinitcpio -P
```

Beim Entfernen von `hgos-branding` werden die gesicherten Originaldateien zurückgespielt.

## Hinweise

- GRUB wird nur angepasst, wenn `/boot/grub/grub.cfg` existiert. Mit Limine oder systemd-boot bleibt das Startmenü unverändert.
- Ein zusätzlich installiertes `cachy-update` (anderer Updater) bleibt erhalten; bei Bedarf `sudo pacman -R cachy-update`, damit nur ein Update-Symbol erscheint.
