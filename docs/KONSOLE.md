# Hard Gaming Konsole (`hgos-konsole`)

Optionaler Konsolenmodus für Hard Gaming OS: eine mit dem Controller bedienbare
Oberfläche für Spiele aus Steam, Heroic und Lutris – im Stil von SteamOS, aber
komplett Hard Gaming. Grundlage ist ein Fork von **OpenGamepadUI** (GPLv3), der
aus dem Quellcode gebaut und auf Hard Gaming gebrandet wird.

**Nicht verpflichtend.** Ohne Installation ändert sich am System nichts. Mit
Installation gibt es zusätzlich die Sitzung „Hard Gaming Konsole“ im
Anmeldebildschirm; der normale Desktop bleibt Standard.

## Stand 2.7.0 (erste Beta der Konsole)

| Bereich | Stand |
|---|---|
| Name, Logo, Startvideo | Hard Gaming |
| Farben | Theme „Hard Gaming“ (aus „Dark Soul“ umgefärbt), Standard |
| Selbst-Updater von OpenGamepadUI | aus – Updates nur über das Update Center / Repo `[hardgaming]` |
| Sitzung im Anmeldebildschirm | „Hard Gaming Konsole“ mit Sicherheitsnetz (siehe unten) |
| Fenster-Modus vom Desktop | Startmenü → Hard Gaming Konsole |
| Steam-/Lutris-Spiele | über die Erweiterungen in der Konsole (Einstellungen → Erweiterungen) |
| Heroic-Spiele | kommt mit 2.8.0 (eigene Erweiterung) |
| Sprache | Oberfläche noch Englisch; deutsche Übersetzung folgt |
| Eigene Schnelleinstellungen, „direkt in Konsole starten“ | geplant für 2.8.0 |

## Sicherheitsnetz

`/usr/lib/hard-gaming-os/konsole-session` prüft vor dem Start:

- gamescope und das Konsolen-Programm vorhanden,
- Vulkan-fähige Grafik vorhanden,
- bei NVIDIA: Treiber mit `nvidia_drm.modeset=1`.

Schlägt eine Prüfung fehl oder bricht die Konsole in den ersten 20 Sekunden ab,
startet automatisch der normale KDE-Desktop. Protokoll:
`~/.local/state/hard-gaming-konsole.log`.

Bei Hybrid-Grafik (Laptop mit NVIDIA) rendert die Konsole auf der NVIDIA-Karte.
Sie wird **nie** auf eine kleine interne Grafik gezwungen – das hatte beim
ersten Test (Radeon 610M) den Grafikspeicher gefüllt und das System eingefroren.
Einstellungen: `/etc/hard-gaming-os/konsole.conf`, pro Benutzer
`~/.config/hard-gaming-konsole.conf`.

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
