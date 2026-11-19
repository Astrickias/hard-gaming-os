#!/usr/bin/env python3
"""Generate a reviewed Calamares packages-module proposal; never installs packages."""
import argparse
from pathlib import Path
import re
import sys

NAME = re.compile(r"[A-Za-z0-9@._+\-]+\Z")

def packages(path):
    names = []
    for line in path.read_text(encoding="utf-8").splitlines():
        item = line.strip()
        if not item or item.startswith("#"):
            continue
        if not NAME.fullmatch(item):
            raise ValueError(f"Invalid package name: {item!r}")
        if item not in names:
            names.append(item)
    if not names:
        raise ValueError("Empty manifest")
    return names

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("edition", choices=("gaming", "allround"))
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    args = parser.parse_args()
    manifest = args.root / "config" / "editions" / f"{args.edition}.packages"
    selected = packages(manifest)
    output = args.root / "build" / args.edition / "calamares" / "integration" / "packages-hgos.conf"
    output.parent.mkdir(parents=True, exist_ok=True)
    # Calamares packages module YAML structure; insertion must be reviewed against pinned upstream.
    output.write_text("# PROPOSAL ONLY: do not enable before pinned upstream sequence validation\n"
                      "backend: pacman\n"
                      "operations:\n"
                      "  - install:\n" + "".join(f"      - {p}\n" for p in selected), encoding="utf-8")
    print(f"{args.edition}: {len(selected)} packages -> {output}")
    return 0

if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError) as exc:
        print(exc, file=sys.stderr)
        sys.exit(2)
