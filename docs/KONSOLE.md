# Hard Gaming Konsole (`hgos-konsole`)

Optionaler Konsolenmodus für Hard Gaming OS: eine mit dem Controller bedienbare
Oberfläche für Spiele aus Steam, Heroic und Lutris – im Stil von SteamOS, aber
komplett Hard Gaming. Grundlage ist ein Fork von **OpenGamepadUI** (GPLv3), der
aus dem Quellcode gebaut und auf Hard Gaming gebrandet wird.

**Nicht verpflichtend.** Ohne Installation ändert sich am System nichts. Mit
Installation gibt es zusätzlich die Sitzung „Hard Gaming Konsole“ im
Anmeldebildschirm; der normale Desktop bleibt Standard.

## Stand 2.7.1 (Beta)

| Bereich | Stand |
|---|---|
| Name, Logo, Startvideo | Hard Gaming |
| Farben | Theme „Hard Gaming“ (aus „Dark Soul“ umgefärbt), Standard |
| Selbst-Updater von OpenGamepadUI | aus – Updates nur über das Update Center / Repo `[hardgaming]` |
| Sitzung im Anmeldebildschirm | „Hard Gaming Konsole“ mit Sicherheitsnetz; auf Hybrid-Laptops vorerst gesperrt |
| Fenster-Modus vom Desktop | Startmenü → Hard Gaming Konsole (normales Fenster, ohne gamescope) |
| Steam-/Lutris-Spiele | über die Erweiterungen in der Konsole (Einstellungen → Erweiterungen) |
| Heroic-Spiele | kommt mit 2.8.0 (eigene Erweiterung) |
| Sprache | Oberfläche noch Englisch; deutsche Übersetzung folgt |
| Eigene Schnelleinstellungen, „direkt in Konsole starten“ | geplant für 2.8.0 |

## Sicherheitsnetz (seit 2.7.1)

**Fenster-Modus** (Startmenü → Hard Gaming Konsole) läuft als normales Fenster
ohne gamescope. Auf Laptops mit NVIDIA + interner Grafik rendert er per
PRIME-Offload auf der NVIDIA-Karte. In 2.7.0 lief er in einem verschachtelten
gamescope – das hat auf einem ROG Strix (RTX 4070 + Radeon 610M) den ganzen
Bildschirm schwarz gemacht. Der alte Weg ist nur noch per
`KONSOLE_FENSTER_GAMESCOPE=1` und nur auf Geräten mit einer Grafikkarte möglich.

**Sitzung** (`/usr/lib/hard-gaming-os/konsole-session`):

- Prüfungen vor dem Start: gamescope, Konsolen-Programm, Vulkan, bei NVIDIA
  `nvidia_drm.modeset=1`.
- **Hybrid-Laptops gesperrt** (NVIDIA + interne Grafik), bis die Sitzung dort
  gezielt getestet ist. Freigabe zum Testen: `KONSOLE_HYBRID_SITZUNG=1`.
- **Wächter**: Ist die Oberfläche nach 25 s nicht geladen, wird gamescope
  beendet.
- In allen drei Fällen startet automatisch der normale KDE-Desktop.

**Notausgang**, falls trotzdem alles schwarz bleibt: **Strg + Alt + F3**,
anmelden, `hgos-konsole-beenden` eingeben, mit **Strg + Alt + F1** (oder F2)
zurück zum Anmeldebildschirm und dort „Plasma“ wählen.

Protokoll: `~/.local/state/hard-gaming-konsole.log`. Einstellungen:
`/etc/hard-gaming-os/konsole.conf`, pro Benutzer `~/.config/hard-gaming-konsole.conf`.

## Testen – zuerst nur in einer VM

1. Hard-Gaming-OS-VM starten (virt-manager), System aktualisieren.
2. `sudo pacman -Sy hgos-konsole` (oder Hello → Gaming → Hard Gaming Konsole).
3. Fenster-Modus: Startmenü → Hard Gaming Konsole.
4. Sitzung: abmelden, unten im Anmeldebildschirm „Hard Gaming Konsole“ wählen.
   In einer VM ohne echte 3D-Beschleunigung startet gamescope meist nicht –
   dann muss automatisch der Desktop kommen (das testet das Sicherheitsnetz).
5. Log ansehen: `cat ~/.local/state/hard-gaming-konsole.log`.

Erst wenn das in der VM sauber läuft, auf echter Hardware probieren.

## Bauen

Gebaut wird im GitHub-Workflow („Pakete“, eigener Schritt; „Konsole Testbau“
für Pull Requests mit Download-Artefakt). Lokal:

```bash
sudo pacman -S --needed base-devel git godot rust clang wget unzip ffmpeg python-pillow
HGOS_BUILD_KONSOLE=1 HGOS_NUR_PAKET=hgos-konsole ./scripts/build-packages.sh out/
```

Benötigt Netz (Rust-Crates, Godot-Exportvorlagen ≈ 1 GB) und Godot 4.7.

## Upstream-Version wechseln

`_ogui_commit` und `_ogui_version` im PKGBUILD ändern. `brand-konsole.py`
bricht ab, wenn eine erwartete Stelle im Quellcode fehlt – dann die Ersetzung
anpassen, nie stillschweigend überspringen.
