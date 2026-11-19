#!/usr/bin/env python3
"""Hard Gaming Update Center: sichtbares Branding und deutsche Haupttexte für cachy-updater.

Arbeitet auf dem gepinnten Upstream-Commit (siehe PKGBUILD). Jede Ersetzung muss
genau passen, sonst bricht der Paketbau ab: so fällt eine geänderte Upstream-Datei
sofort auf, statt still englische oder CachyOS-Texte durchzulassen.
Technische Kennungen (Binary cachyos-updater, org.cachyos.updater, Units, Polkit)
bleiben unverändert, damit Update-Logik und Rechteverwaltung wie upstream arbeiten.
Lizenz des Originals: GPL-3.0-or-later (bleibt erhalten).
"""
import argparse
import shutil
from pathlib import Path

NAME = "Hard Gaming Update Center"

# Datei -> [(alt, neu)]. Alle Pfade relativ zu native/.
REPLACE = {
    "qml/Main.qml": [
        ('title: "Cachy Updater"', f'title: "{NAME}"'),
        ('{ name: "Updates", icon:', '{ name: "Updates", icon:'),
        ('subtitle: "Repo, AUR, and Flatpak \\u2014 with clear change summaries." }',
         'subtitle: "Repo, AUR und Flatpak \\u2014 mit verständlicher Übersicht." }'),
        ('{ name: "News", icon: "news-subscribe",\n          subtitle: "Arch and CachyOS announcements." }',
         '{ name: "Neuigkeiten", icon: "news-subscribe",\n          subtitle: "Ankündigungen von Arch Linux und CachyOS, der Basis von Hard Gaming OS." }'),
        ('{ name: "Cleanup", icon: "edit-clear-all",\n          subtitle: "Orphans, cache, kernels, Flatpak, and AUR maintenance." }',
         '{ name: "Aufräumen", icon: "edit-clear-all",\n          subtitle: "Verwaiste Pakete, Cache, Kernel, Flatpak und AUR." }'),
        ('subtitle: "Device firmware via fwupd." }', 'subtitle: "Geräte-Firmware über fwupd." }'),
        ('{ name: "History", icon: "view-list-details",\n          subtitle: "Recent apply and maintenance actions." }',
         '{ name: "Verlauf", icon: "view-list-details",\n          subtitle: "Zuletzt ausgeführte Updates und Wartung." }'),
        ('{ name: "Settings", icon: "configure",\n          subtitle: "Tray, sources, holds, and performance options." }',
         '{ name: "Einstellungen", icon: "configure",\n          subtitle: "Benachrichtigung, Quellen, gesperrte Pakete und Leistung." }'),
        ('text: "Refresh"', 'text: "Aktualisieren"'),
        ('QQC2.ToolTip.text: "Refresh (R)"', 'QQC2.ToolTip.text: "Neu prüfen (R)"'),
        ('QQC2.ToolTip.text: "Stop the current operation (Esc)"', 'QQC2.ToolTip.text: "Laufenden Vorgang stoppen (Esc)"'),
        ('QQC2.MenuItem { text: "Dry Run";', 'QQC2.MenuItem { text: "Probelauf";'),
        ('QQC2.MenuItem { text: "Download Only";', 'QQC2.MenuItem { text: "Nur herunterladen";'),
        ('text: "Apply " + Updater.selectedCount + " update" + (Updater.selectedCount === 1 ? "" : "s")',
         'text: Updater.selectedCount + (Updater.selectedCount === 1 ? " Update" : " Updates") + " installieren"'),
        ('QQC2.ToolTip.text: "Apply selected updates (Ctrl+Enter)"', 'QQC2.ToolTip.text: "Ausgewählte Updates installieren (Strg+Enter)"'),
        ('text: "The following commands will run:"', 'text: "Diese Befehle werden ausgeführt:"'),
        ('text: "A reboot will be required afterward."', 'text: "Danach ist ein Neustart nötig."'),
        ('title: "Reboot required"', 'title: "Neustart erforderlich"'),
        ('subtitle: "Important system packages were updated."', 'subtitle: "Wichtige Systempakete wurden aktualisiert."'),
        ('Kirigami.Action { text: "Later";', 'Kirigami.Action { text: "Später";'),
        ('Kirigami.Action { text: "Reboot now";', 'Kirigami.Action { text: "Jetzt neu starten";'),
        ('title: "Stop the current operation?"', 'title: "Laufenden Vorgang stoppen?"'),
        ('Kirigami.Action { text: "Keep running";', 'Kirigami.Action { text: "Weiterlaufen lassen";'),
    ],
    "qml/pages/UpdatesPage.qml": [
        ('text: "I\'ve read the Arch news"', 'text: "Ich habe die Neuigkeiten gelesen"'),
        ('text: "Select all updates"', 'text: "Alle Updates auswählen"'),
        ('text: "A reboot is required after these updates finish."', 'text: "Nach diesen Updates ist ein Neustart nötig."'),
        ('text: "Reboot now"', 'text: "Jetzt neu starten"'),
        ('placeholderText: "Search packages…"', 'placeholderText: "Pakete suchen …"'),
        ('text: "Important only"', 'text: "Nur wichtige"'),
        ('QQC2.ToolTip.text: "Select only important and critical updates"', 'QQC2.ToolTip.text: "Nur wichtige und kritische Updates auswählen"'),
        ('text: "Select all"', 'text: "Alle auswählen"'),
        ('text: "Showing " + list.count + " of " + Updater.packageCount + " packages"',
         'text: list.count + " von " + Updater.packageCount + " Paketen"'),
        ('text: "Clear filters"', 'text: "Filter zurücksetzen"'),
    ],
    "qml/pages/SettingsPage.qml": [
        ('QQC2.Label { text: "General";', 'QQC2.Label { text: "Allgemein";'),
        ('QQC2.Label { text: "Default tab";', 'QQC2.Label { text: "Start-Tab";'),
        ('text: "Check for updates on startup"', 'text: "Beim Start nach Updates suchen"'),
        ('text: "Offline mode (use cached check results)"', 'text: "Offline-Modus (letzte Prüfung verwenden)"'),
        ('text: "Enable AUR checks"', 'text: "AUR prüfen"'),
        ('text: "Enable Flatpak checks"', 'text: "Flatpak prüfen"'),
        ('text: "Enable news fetches"', 'text: "Neuigkeiten laden"'),
        ('QQC2.Label { text: "Tray & notifications";', 'QQC2.Label { text: "Symbol & Benachrichtigungen";'),
        ('QQC2.Label { text: "Tray check interval (minutes)";', 'QQC2.Label { text: "Prüfintervall im Hintergrund (Minuten)";'),
        ('text: "Notify only for important updates"', 'text: "Nur bei wichtigen Updates benachrichtigen"'),
        ('QQC2.Label { text: "Performance & safety";', 'QQC2.Label { text: "Leistung & Sicherheit";'),
        ('text: "Create snapper snapshot before applying updates"', 'text: "Vor Updates einen Snapshot anlegen (snapper)"'),
        ('QQC2.Label { text: "Held packages";', 'QQC2.Label { text: "Gesperrte Pakete";'),
        ('text: "No held packages"', 'text: "Keine gesperrten Pakete"'),
        ('placeholderText: "Package name"', 'placeholderText: "Paketname"'),
        ('text: "Hold"', 'text: "Sperren"'),
    ],
    "src/TrayController.cpp": [
        ('m_tray->setToolTip(QStringLiteral("Cachy Updater"));', f'm_tray->setToolTip(QStringLiteral("{NAME}"));'),
        ('QStringLiteral("Open Cachy Updater")', 'QStringLiteral("Update Center öffnen")'),
        ('QStringLiteral("Check for updates")', 'QStringLiteral("Nach Updates suchen")'),
        ('m_applyAction = m_menu->addAction(QStringLiteral("Apply all updates")', 'm_applyAction = m_menu->addAction(QStringLiteral("Alle Updates installieren")'),
        ('m_quitAction = m_menu->addAction(QStringLiteral("Quit")', 'm_quitAction = m_menu->addAction(QStringLiteral("Beenden")'),
        ('QStringLiteral("Apply all updates?")', 'QStringLiteral("Alle Updates installieren?")'),
        ('QStringLiteral("Apply 1 pending update now?")', 'QStringLiteral("1 Update jetzt installieren?")'),
        ('QStringLiteral("Apply all %1 pending updates now?")', 'QStringLiteral("Alle %1 Updates jetzt installieren?")'),
        ('QStringLiteral("1 update available")', 'QStringLiteral("1 Update verfügbar")'),
        ('QStringLiteral("%1 updates available").arg(count);\n', 'QStringLiteral("%1 Updates verfügbar").arg(count);\n'),
        ('QStringLiteral(" (%1 important)")', 'QStringLiteral(" (%1 wichtig)")'),
        ('m_tray->showMessage(QStringLiteral("Cachy Updater"), body,', f'm_tray->showMessage(QStringLiteral("{NAME}"), body,'),
        ('QStringLiteral("Cachy Updater — %1 (%2%)")', f'QStringLiteral("{NAME} — %1 (%2%)")'),
        ('QStringLiteral("Cachy Updater — 1 update available")', f'QStringLiteral("{NAME} — 1 Update verfügbar")'),
        ('QStringLiteral("Cachy Updater — %1 updates available")', f'QStringLiteral("{NAME} — %1 Updates verfügbar")'),
        ('QStringLiteral("Cachy Updater — up to date")', f'QStringLiteral("{NAME} — alles aktuell")'),
    ],
    "src/NewsController.cpp": [
        ('"CachyOS news feed unavailable right now (Arch news still shown).")',
         '"Die CachyOS-Neuigkeiten sind gerade nicht erreichbar (Arch-Neuigkeiten werden weiter angezeigt).")'),
    ],
    "src/main.cpp": [
        ('app.setOrganizationName(QStringLiteral("CachyOS"));', 'app.setOrganizationName(QStringLiteral("Hard Gaming Labs"));'),
        ('QStringLiteral("CachyOS native system updater")', 'QStringLiteral("Hard Gaming OS Update Center")'),
        ('tray.showMessage(QStringLiteral("Cachy Updater"),', f'tray.showMessage(QStringLiteral("{NAME}"),'),
    ],
    "qml/Theme.qml": [
        ('// CachyOS design tokens.', '// Hard Gaming OS design tokens (aus dem CachyOS-Updater abgeleitet).'),
        ('readonly property color bg: isDark ? "#161719" : "#F4F5F6"', 'readonly property color bg: isDark ? "#151B18" : "#F3F6F4"'),
        ('readonly property color deepBg: isDark ? "#121315" : "#EAECEF"', 'readonly property color deepBg: isDark ? "#0E1310" : "#E8EEEA"'),
        ('readonly property color surface: isDark ? "#1D1E21" : "#FFFFFF"', 'readonly property color surface: isDark ? "#1B231F" : "#FFFFFF"'),
        ('// CachyOS blues + cyan accent', '// Hard-Gaming-Grün als Akzent'),
        ('readonly property color kernel: isDark ? "#0F4C75" : "#1A6FA0"', 'readonly property color kernel: isDark ? "#1F5F2B" : "#2EA043"'),
        ('readonly property color kernelDeep: isDark ? "#0A3D62" : "#E6F2F8"', 'readonly property color kernelDeep: isDark ? "#143D1C" : "#E4F6E7"'),
        ('readonly property color kernelBorder: isDark ? "#1B6699" : "#7EB6D6"', 'readonly property color kernelBorder: isDark ? "#2E8A3E" : "#86D293"'),
        ('readonly property color cyan: "#00B7C2"', 'readonly property color cyan: "#54EF61"'),
        ('readonly property color cyanHover: "#1AC7D1"', 'readonly property color cyanHover: "#72F57D"'),
        ('readonly property color cyanPressed: "#009AA4"', 'readonly property color cyanPressed: "#3FCB4B"'),
        ('readonly property color cyanInk: isDark ? "#062A2E" : "#043033"', 'readonly property color cyanInk: isDark ? "#0B2410" : "#0B2410"'),
        ('readonly property color cyanBg: isDark ? "#0D2A2E" : "#D7F3F5"', 'readonly property color cyanBg: isDark ? "#12301A" : "#DDF8E0"'),
    ],
    "org.cachyos.updater.desktop": [
        ("Name=Cachy Updater", f"Name={NAME}\nName[de]={NAME}"),
        ("GenericName=System Updater", "GenericName=Systemaktualisierung"),
        ("Comment=Fast, native system updater for CachyOS", "Comment=Updates für Hard Gaming OS, Programme und Treiber"),
        ("Keywords=update;pacman;paru;cachy;packages;flatpak;aur;kernel;", "Keywords=update;aktualisieren;pacman;paru;hardgaming;pakete;flatpak;aur;kernel;"),
    ],
    "org.cachyos.updater-tray.desktop": [
        ("Name=Cachy Updater Systray", f"Name={NAME} (Hintergrund)"),
        ("Comment=Background update notifier for Cachy Updater", "Comment=Meldet verfügbare Updates für Hard Gaming OS"),
        ("Keywords=update;pacman;cachy;tray;", "Keywords=update;pacman;hardgaming;tray;"),
    ],
    "org.cachyos.updater.metainfo.xml": [
        ("<name>Cachy Updater</name>", f"<name>{NAME}</name>"),
        ("<summary>Fast native system updater for CachyOS</summary>", "<summary>Systemaktualisierung für Hard Gaming OS</summary>"),
        ("<developer_name>CachyOS</developer_name>", "<developer_name>Hard Gaming Labs</developer_name>"),
        ("Cachy Updater checks and applies", f"{NAME} (basiert auf cachy-updater von akanbaz) checks and applies"),
        ('<url type="homepage">https://cachyos.org</url>', '<url type="homepage">https://hardgaming.net/</url>'),
    ],
    "org.cachyos.updater-tray.service": [("Description=Cachy Updater systray applet", f"Description={NAME} – Symbol in der Taskleiste")],
    "org.cachyos.updater-check.service": [("Description=CachyOS Updater scheduled check", f"Description={NAME} – geplante Prüfung")],
    "org.cachyos.updater-check.timer": [("Description=Daily CachyOS update check", f"Description={NAME} – tägliche Prüfung")],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Upstream-Checkout (enthält native/)")
    parser.add_argument("assets", type=Path, help="Ordner mit logo.svg, tray-uptodate.svg, tray-updates.svg")
    args = parser.parse_args()
    native = args.source / "native"
    for relative, pairs in REPLACE.items():
        path = native / relative
        text = path.read_text(encoding="utf-8")
        for old, new in pairs:
            if old == new:
                continue
            if text.count(old) != 1:
                raise SystemExit(f"Upstream geändert: {relative}: {old[:60]!r} ({text.count(old)}x)")
            text = text.replace(old, new, 1)
        path.write_text(text, encoding="utf-8")
    # Grafiken: SVG-Hüllen mit eingebettetem HG-PNG (erzeugt aus assets/HG OS.png und
    # hg-tray*.png), damit die CMake-Installationsregeln unverändert bleiben.
    for name in ("logo.svg", "tray-uptodate.svg", "tray-updates.svg"):
        shutil.copyfile(args.assets / name, native / "assets" / name)
    print(f"{NAME}: Branding und deutsche Haupttexte angewendet")


if __name__ == "__main__":
    main()
