#!/usr/bin/env python3
"""Brand the visible Qt updater surfaces while keeping its technical IDs."""
import argparse
from pathlib import Path
import shutil


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("logo", type=Path)
    args = parser.parse_args()
    native = args.source / "native"
    here = Path(__file__).resolve().parent
    title = "Hard Gaming Update Center"
    for relative in (
        "qml/Main.qml", "src/TrayController.cpp", "src/main.cpp",
        "org.cachyos.updater.desktop", "org.cachyos.updater-tray.desktop",
        "org.cachyos.updater.metainfo.xml",
    ):
        path = native / relative
        source = path.read_text()
        branded = source.replace("Cachy Updater", title).replace("CachyOS Updater", title)
        branded = branded.replace("updater for CachyOS", "updater for Hard Gaming OS")
        branded = branded.replace("<developer_name>CachyOS</developer_name>",
                                  "<developer_name>Hard Gaming Labs</developer_name>")
        for old, new in (("logo.svg", "hg-logo.png"),
                         ("tray-uptodate.svg", "hg-tray.png"),
                         ("tray-updates.svg", "hg-tray-updates.png")):
            branded = branded.replace(old, new)
        path.write_text(branded)
    shutil.copyfile(args.logo, native / "assets/hg-logo.png")
    for filename in ("hg-tray.png", "hg-tray-updates.png"):
        shutil.copyfile(here / filename, native / "assets" / filename)
    cmake = native / "CMakeLists.txt"
    source = cmake.read_text()
    for old, new in (("assets/logo.svg", "assets/hg-logo.png"),
                     ("assets/tray-uptodate.svg", "assets/hg-tray.png"),
                     ("assets/tray-updates.svg", "assets/hg-tray-updates.png"),
                     ("scalable/apps", "1024x1024/apps"),
                     ("scalable/status", "128x128/status"),
                     ("RENAME org.cachyos.updater.svg", "RENAME org.cachyos.updater.png"),
                     ("RENAME org.cachyos.updater-tray.svg", "RENAME org.cachyos.updater-tray.png"),
                     ("RENAME org.cachyos.updater-tray-updates.svg", "RENAME org.cachyos.updater-tray-updates.png")):
        if old not in source:
            raise ValueError(f"Unbekannte Updater-Ressource: {old}")
        source = source.replace(old, new)
    cmake.write_text(source)
    print("Hard Gaming Update Center: Titel, Menü, App-Icon und Tray-Grafiken vorbereitet")


if __name__ == "__main__":
    main()
