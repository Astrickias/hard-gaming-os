# Hard Gaming OS

Gaming-Distribution von **Hard Gaming Labs** auf Basis von [CachyOS](https://cachyos.org/) und [Arch Linux](https://archlinux.org/). Eine Edition für Gaming und Alltag: KDE Plasma, Calamares-Installer, Steam, Lutris, Heroic, MangoHud und GameMode, durchgehendes Hard-Gaming-Design vom Bootmenü bis zum Desktop.

Website: [hardgaming.net](https://hardgaming.net/)

## Inhalt

| Pfad | Zweck |
|---|---|
| `scripts/build-release.sh` | Baut die ISO auf einem Arch-/CachyOS-Host (siehe [docs/UPSTREAM.md](docs/UPSTREAM.md)) |
| `scripts/build-cachyos.sh` | Stellt das CachyOS-Live-Profil (fester Upstream-Commit) mit HG-Anpassungen bereit |
| `scripts/build-packages.sh` | Baut die HG-Pakete mit `makepkg` |
| `packaging/hgos-branding` | GRUB-Theme, Plymouth, Wallpaper, Plasma-Design, Farbschema, fastfetch |
| `packaging/hgos-update-center` | Hard Gaming Update Center (Fork von cachy-updater) |
| `packaging/hgos-umstieg` | Umstieg von CachyOS ohne Neuinstallation ([docs/UMSTIEG.md](docs/UMSTIEG.md)) |
| `apps/hg-welcome` | Hello Hard Gaming OS (Qt-Quick-App) |
| `installer/` | Calamares-Branding und Installations-Hooks |
| `config/editions/` | Paketliste |
| `dist/Aenderungsliste-*.md` | Änderungslisten je Version |
| `docs/` | Build, VM-Test, Testberichte |

## ISO bauen

```bash
./scripts/test-integration.sh
sudo env HGOS_UPSTREAM_REF=3215497d2e8c5fea90e185affcf973dfa2cf790b \
  HGOS_ACK_EXPERIMENTAL=1 HGOS_ACK_TARGET_UNVERIFIED=1 ./scripts/build-release.sh
```

Testablauf und Prüfliste: [docs/TEST-2.5.0.md](docs/TEST-2.5.0.md).

## Versionen

Jede Version ist ein Tag (`v2.1.4`, `v2.4.0` …). Eine veröffentlichte Version wird nie nachträglich geändert; jede Änderung bekommt eine neue Versionsnummer.

## Lizenz und Marke

Siehe [NOTICE.md](NOTICE.md). Kurz: Der Code steht unter den jeweiligen freien Lizenzen, Name und Logos „Hard Gaming“ sind nicht freigegeben.
