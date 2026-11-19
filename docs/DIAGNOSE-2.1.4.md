# Live-Boot-Diagnose und VM-Abnahme · 2.1.4 Beta

## Stand

2.1.4 wurde **nicht** als ISO gebaut und **nicht** gebootet. Die Arbeitsumgebung hatte kein Arch/CachyOS, kein `pacman`/`mkarchiso`, kein QEMU, kein KVM und keinen Zugriff auf die Paketspiegel. Geprüft wurde statisch am Quellstand und mit einem nachgebauten Mini-Profil (`tests/test_stage_live_branding.py`, Dry-Run von `build-cachyos.sh`).

## Ursachenkandidaten für den dunklen Bildschirm (aus dem Quellstand 2.1.3)

| # | Befund in 2.1.3 | Wirkung | Änderung in 2.1.4 |
|---|---|---|---|
| 1 | Kein `display-manager.service` im Projekt. Die frühere Build-VM brauchte laut Übergabe eine explizite Plasma-Login-Manager-Verknüpfung. | Ohne Login-Manager startet kein Greeter und kein Autologin. | Statische Verknüpfung auf `plasmalogin.service` plus `graphical.target` im Staging, zusätzlich `systemctl enable --force plasmalogin.service` im chroot. Fehlt die Unit, bricht der Build ab. |
| 2 | `build-cachyos.sh` schrieb `customize_airootfs.sh` mit `install -Dm755` und umging damit den Overlay-Konfliktschutz. | Falls Upstream eine eigene Datei mitbringt (Live-User, Dienste), ging deren Inhalt verloren. | HG-Schritt liegt jetzt in `/root/hgos-customize-airootfs.sh` und wird an eine vorhandene Upstream-Datei angehängt. |
| 3 | `stage-live-branding.py` öffnete `plasmalogin.conf` mit `open("a")`. | Fehlte die Upstream-Datei, entstand still eine Datei ohne Autologin-Sektion. | Build bricht ab, wenn die Upstream-Datei fehlt. |
| 4 | `quiet splash` und der Plymouth-Hook vor den archiso-Hooks. | Jeder Fehler beim Finden oder Einhängen des Live-Mediums verschwindet hinter dem Splash, Ergebnis wirkt wie „dunkel“. | Neue Diagnose-Menüeinträge (GRUB und Syslinux, Standard- und LTS-Kernel) ohne Splash, mit `plymouth.enable=0` und `console=ttyS0,115200n8`. |
| 5 | Unklar, ob das verwendete archiso `customize_airootfs.sh` noch ausführt. | Dann wurden weder die Live-initramfs noch andere Anpassungen erzeugt. | Der HG-Schritt hinterlässt `/usr/share/hard-gaming-os/customize-ran`. Fehlt die Datei im Live-System, lief der Schritt nicht. Die statische Login-Verknüpfung (Punkt 1) wirkt unabhängig davon. |

Welche dieser Ursachen tatsächlich greift, entscheidet erst das serielle Log.

## Ablauf in der Build-VM

```bash
./scripts/test-integration.sh
sudo env HGOS_UPSTREAM_REF=3215497d2e8c5fea90e185affcf973dfa2cf790b \
  HGOS_ACK_EXPERIMENTAL=1 HGOS_ACK_TARGET_UNVERIFIED=1 ./scripts/build-release.sh gaming

ISO=dist/iso/Hard-Gaming-OS-gaming-2.1.4-beta-x86_64.iso
./scripts/vm-test.sh live   "$ISO" uefi     # im Menü „(Diagnose: seriell, ohne Splash)“ wählen
./scripts/vm-test.sh live   "$ISO" bios
./scripts/vm-test.sh direct "$ISO" std      # Kernel + initramfs direkt, Parameter aus dem ISO-Menü
./scripts/vm-test.sh direct "$ISO" lts
```

Logs liegen unter `dist/vm/<ISO-Name>/logs/`. So liest du sie:

- **Endet das Log vor `Mounting '/dev/disk/by-uuid/...' to '/run/archiso/bootmnt'`** oder mit `ERROR: '...' device did not show up`: Fehler vor dem Root-Mount, also Label/UUID, initramfs oder Hooks.
- **`Reached target Multi-User System`, aber kein `Started Plasma Login Manager`**: Login-Manager fehlt oder ist nicht verknüpft.
- **`plasmalogin.service: Failed` oder Absturz von `plasmalogin-greeter`**: Fehler beim grafischen Login. Dann `journalctl -b -u plasmalogin` auf tty2 sichern.

## Installation und Neustart

1. Regulären Eintrag booten. Screenshot: `./scripts/vm-test.sh shot <ISO-Name> 01-live-desktop`.
2. „Hard Gaming OS installieren“ öffnen und auf die leere Platte installieren. Danach `/home/liveuser/.cache/calamares/session.log` sichern.
3. VM beenden und ohne ISO starten: `./scripts/vm-test.sh disk <ISO-Name> uefi`, für BIOS dieselbe Platte mit `bios` (vorher im BIOS-Modus installieren).
4. Prüfen: Plymouth, Login, Wallpaper, Hello mit beiden Links, Systeminfo (`hgos-about`), `cat /usr/share/hard-gaming-os/edition`, `pacman -Q steam lutris heroic-games-launcher` (Gaming) bzw. deren Fehlen (Allround).

Bei UEFI legt das Skript pro VM eine eigene `OVMF_VARS.fd` an, damit der Booteintrag von Calamares den Neustart übersteht.

## Update Center

Nicht im Image. `build-cachyos.sh` bindet `apps/hg-update-center/` nicht ein. Laut `integration-plan.md` folgt das erst nach einem eigenen Paketbau. Außerdem entfernt `hgos-calamares-runtime` `cachy-update` aus der Netinstall-Auswahl für das Zielsystem. Ohne neuen Updater hat das installierte System damit keinen grafischen Updater.
