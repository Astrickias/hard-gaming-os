# Hard Gaming Update Center – Upstream-Integrationspaket

Technische Basis: https://github.com/akanbaz/cachy-updater (C++ / KDE Kirigami).

**Status:** Vorbereitete Quellcode-Fork-Integration, noch kein gebautes oder getestetes Programm.

`prepare-fork.sh` lädt den Quellcode auf einem Rechner mit Netzwerkzugang, ersetzt ausschließlich sichtbare Branding-Texte in QML und Desktop-Dateien und übernimmt das originale HG-Logo. Es ändert keine Update-Logik und installiert keine Pakete. Die ursprüngliche Lizenz muss beibehalten werden. Vor einer Weiterverteilung Lizenz und Rechte prüfen.

## CachyOS-Buildrechner

```bash
sudo pacman -S --needed git cmake ninja gcc qt6-base qt6-declarative kirigami qqc2-desktop-style breeze-icons pacman polkit
bash apps/hg-update-center/prepare-fork.sh
cd build/hg-update-center/upstream/native
cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
./build/cachyos-updater
```

Das Upstream-Binary heißt vorerst weiter `cachyos-updater`; der Dateiname ist nicht Teil des sichtbaren Produktbrandings. Eine Umbenennung und eine echte Paketierung sind nach einem erfolgreichen Build zu prüfen.

**Sicherheit:** Keine `sudo cmake --install`-Ausführung auf dem Hauptrechner vor einem VM-Test. AUR- und Flatpak-Aktionen nur über die Originalimplementierung.
