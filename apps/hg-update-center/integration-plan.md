# Integration in Hard Gaming OS

1. Fork gegen einen festen Git-Commit testen und Lizenz kontrollieren.
2. QML-Branding prüfen: Texte, Header, About-Dialog, Tray und Benachrichtigungen. Die vorhandene Textanpassung deckt nicht alle Stellen ab.
3. HG-Logo als tatsächliches Icon in QML, .desktop und Tray integrieren.
4. CMake-Build und Anwendung in einer CachyOS-VM starten; Repo-/AUR-/Flatpak-Updates testen.
5. Als eigenes Arch-Paket paketieren, Upstream-Programmkonflikte beachten.
6. Offiziellen CachyOS-Update-Tray-Autostart deaktivieren, damit nur ein Updater Benachrichtigungen auslöst.
7. In Hard Gaming Welcome verlinken und beide Editions-Paketlisten erweitern, **erst nach erfolgreichem Paketbau**.
8. Keine automatische Updateinstallation ohne ausdrückliche Benutzeraktion.
