#!/usr/bin/env python3
"""Read-only package audit against the target's pacman local database."""
import argparse
from pathlib import Path
import re
import sys


def audit(root: Path, manifest: Path):
    db = root / "var/lib/pacman/local"
    if not db.is_dir():
        raise ValueError("Pacman-Datenbank im Zielsystem fehlt")
    names = []
    for line in manifest.read_text(encoding="utf-8").splitlines():
        name = line.strip()
        if not name or name.startswith("#"):
            continue
        if not re.fullmatch(r"[a-zA-Z0-9@._+\-]+", name):
            raise ValueError(f"Ungültiger Paketname: {name}")
        names.append(name)
    if not names:
        raise ValueError("Paketmanifest leer")
    installed = set()
    for desc in db.glob("*/desc"):
        lines = desc.read_text(encoding="utf-8", errors="replace").splitlines()
        for i, line in enumerate(lines[:-1]):
            if line == "%NAME%":
                installed.add(lines[i+1])
                break
    missing = sorted(set(names) - installed)
    return names, missing


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("target", type=Path)
    parser.add_argument("manifest", type=Path)
    args = parser.parse_args()
    if args.target.resolve() == Path("/"):
        raise ValueError("Host-Root als Ziel verweigert")
    names, missing = audit(args.target, args.manifest)
    print(f"Geprüfte Editionspakete: {len(set(names))}")
    if missing:
        print("Fehlende Pakete: " + ", ".join(missing), file=sys.stderr)
        return 1
    print("Alle Editionspakete in der lokalen Pacman-Datenbank vorhanden")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError) as exc:
        print(f"Paket-Audit: {exc}", file=sys.stderr)
        sys.exit(2)
