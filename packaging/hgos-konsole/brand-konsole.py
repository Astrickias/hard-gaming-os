#!/usr/bin/env python3
"""Hard-Gaming-Branding für den OpenGamepadUI-Quellcode (Fork „Hard Gaming Konsole“).

Aufruf: brand-konsole.py QUELLVERZEICHNIS LOGO.png [BOOTVIDEO.ogv]

Ändert nur sichtbare Dinge (Name, Logo, Farben, Startvideo) und schaltet den
eingebauten Selbst-Updater ab – Updates kommen ausschließlich über das Paket-Repo
[hardgaming]. Jede Ersetzung wird geprüft: passt eine Stelle nicht mehr (neue
Upstream-Version), bricht der Bau mit einer klaren Meldung ab, statt still ein
halb gebrandetes Paket zu erzeugen.
"""
from __future__ import annotations

import re
import shutil
import sys
from pathlib import Path

SRC = Path(sys.argv[1]).resolve()
LOGO = Path(sys.argv[2]).resolve()
VIDEO = Path(sys.argv[3]).resolve() if len(sys.argv) > 3 and sys.argv[3] else None

NAME = "Hard Gaming Konsole"
LOGO_RES = "res://assets/images/hard-gaming-logo.png"

# Dark-Soul-Farben → Hard-Gaming-Grün (wie Desktop, GRUB und Update Center).
# Schlüssel: exakter Godot-Farbtext aus dem Upstream-Theme.
FARBEN = {
    # Hintergründe (blau-grau → dunkles Grün)
    "Color(0.0823529, 0.0862745, 0.105882, 1)": "Color(0.0627451, 0.105882, 0.0862745, 1)",  # #101b16
    "Color(0.0823529, 0.0862745, 0.109804, 1)": "Color(0.0627451, 0.105882, 0.0862745, 1)",
    "Color(0.0745098, 0.0784314, 0.0941176, 1)": "Color(0.0470588, 0.0823529, 0.0666667, 1)",  # #0c1511
    "Color(0.0588235, 0.0588235, 0.0745098, 1)": "Color(0.0313725, 0.0627451, 0.0470588, 1)",  # #08100c
    "Color(0.133333, 0.137255, 0.180392, 1)": "Color(0.0941176, 0.168627, 0.133333, 1)",  # #182b22
    "Color(0.266667, 0.278431, 0.352941, 1)": "Color(0.168627, 0.27451, 0.219608, 1)",  # #2b4638
    "Color(0.384314, 0.447059, 0.643137, 1)": "Color(0.443137, 0.588235, 0.505882, 1)",  # #719681
    # Akzente (Pink/Lila → Hard-Gaming-Grün)
    "Color(0.937255, 0.0392157, 0.415686, 1)": "Color(0.329412, 0.937255, 0.380392, 1)",  # #54ef61
    "Color(0.913725, 0.0901961, 0.439216, 1)": "Color(0.329412, 0.937255, 0.380392, 1)",
    "Color(0.815686, 0.129412, 0.517647, 1)": "Color(0.184314, 0.74902, 0.235294, 1)",  # #2fbf3c
    "Color(0.803922, 0.184314, 0.537255, 1)": "Color(0.247059, 0.839216, 0.294118, 1)",  # #3fd64b
    "Color(0.741176, 0.576471, 0.976471, 1)": "Color(0.435294, 0.941176, 0.478431, 1)",  # #6ff07a
    "Color(0.699883, 0.4998, 0.98, 1)": "Color(0.435294, 0.941176, 0.478431, 1)",
    "Color(0.8085, 0.686, 0.98, 1)": "Color(0.615686, 0.968627, 0.647059, 1)",  # #9df7a5
    "Color(1, 0.47451, 0.776471, 1)": "Color(0.615686, 0.968627, 0.647059, 1)",
}


def fail(msg: str) -> None:
    print(f"brand-konsole: {msg}", file=sys.stderr)
    sys.exit(1)


def edit(rel: str, old: str, new: str, count: int | None = None) -> None:
    path = SRC / rel
    text = path.read_text(encoding="utf-8")
    found = text.count(old)
    if found == 0 or (count is not None and found != count):
        fail(f"{rel}: erwartete Stelle nicht gefunden ({found}×): {old!r}")
    path.write_text(text.replace(old, new), encoding="utf-8")


def main() -> None:
    if not (SRC / "project.godot").is_file():
        fail(f"kein OpenGamepadUI-Quellcode in {SRC}")

    # 1. Name und Programmsymbol
    edit("project.godot", 'config/name="Open Gamepad UI"', f'config/name="{NAME}"', 1)
    edit("project.godot", 'config/icon="res://icon.svg"', f'config/icon="{LOGO_RES}"', 1)
    edit("core/ui/card_ui/settings/settings_menu.tscn", 'text = "OpenGamepadUI"', f'text = "{NAME}"', 1)
    edit("core/main.gd", '"OpenGamepadUI open source game launcher"',
         f'"{NAME} – basiert auf OpenGamepadUI (GPLv3)"', 1)

    # 2. Logo: Upstream-Symbol überall durch das Hard-Gaming-Logo ersetzen
    shutil.copyfile(LOGO, SRC / "assets/images/hard-gaming-logo.png")
    pattern = re.compile(r'(uid="uid://[a-z0-9]+" )?path="res://icon\.svg"')
    swapped = 0
    for path in list(SRC.rglob("*.tscn")) + list(SRC.rglob("*.tres")):
        if ".godot" in path.parts:
            continue
        text = path.read_text(encoding="utf-8")
        new, n = pattern.subn(f'path="{LOGO_RES}"', text)
        if n:
            # Typ des Verweises bleibt Texture2D; PNG wird beim Import zur Textur.
            path.write_text(new, encoding="utf-8")
            swapped += n
    for rel in ("core/ui/components/toast.gd", "core/ui/card_ui/navigation/in-game_notification.gd",
                "core/ui/components/notification_container.gd"):
        edit(rel, 'preload("res://icon.svg")', f'preload("{LOGO_RES}")', 1)
    if swapped < 3:
        fail(f"zu wenige Logo-Verweise ersetzt ({swapped})")

    # 3. Farbschema: „Dark Soul“ wird zu „Hard Gaming“ (bleibt Standard-Theme)
    theme_files = [SRC / "assets/themes/card_ui-darksoul.tres", *sorted((SRC / "assets/styles/darksoul").glob("*.tres"))]
    changed = 0
    for path in theme_files:
        text = path.read_text(encoding="utf-8")
        for old, new in FARBEN.items():
            if old in text:
                text = text.replace(old, new)
                changed += 1
        path.write_text(text, encoding="utf-8")
    if changed < 10:
        fail(f"Theme-Farben nicht gefunden ({changed} Treffer) – Upstream-Theme hat sich geändert")
    edit("core/ui/card_ui/settings/general_settings_menu.tscn", 'text = "Dark Soul"', 'text = "Hard Gaming"', 1)

    # 4. Selbst-Updater aus: Updates nur über pacman/[hardgaming]
    edit("core/systems/updater/software_updater.gd",
         'func check_for_updates() -> void:\n',
         'func check_for_updates() -> void:\n'
         '\t# Hard Gaming OS: Updates kommen über das Paket-Repo [hardgaming].\n'
         '\tlogger.info("Selbst-Updater deaktiviert – Updates über das Hard Gaming Update Center")\n'
         '\tupdate_available.emit(false)\n'
         '\treturn\n', 1)

    # 5. Startvideo (Upstream-Logo-Animation) durch Hard-Gaming-Intro ersetzen
    if VIDEO is not None:
        if not VIDEO.is_file() or VIDEO.stat().st_size < 1024:
            fail(f"Startvideo fehlt oder ist leer: {VIDEO}")
        shutil.copyfile(VIDEO, SRC / "assets/videos/boot.ogv")

    print(f"brand-konsole: {NAME} gebrandet ({swapped} Logo-Verweise, {changed} Farbersetzungen)")


if __name__ == "__main__":
    main()
