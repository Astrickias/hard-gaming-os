#!/usr/bin/env python3
"""Patch the freshly downloaded CachyOS Calamares configuration before launch.
Only runs in the live environment, never modifies host /etc during builds.
"""
import argparse
import re
from pathlib import Path
import sys


def patch(text):
    anchors = ("instances:\n", "  - packages@online\n", "  - umount\n", "branding: cachyos\n", "  - plymouthcfg\n", "  - netinstall\n")
    if any(text.count(anchor) != 1 for anchor in anchors):
        raise ValueError("Unbekannte Calamares-Konfiguration")
    _, packages, unmount, branding, plymouth, netinstall = anchors
    if not text.index(packages) < text.index(plymouth) < text.index(unmount) or "@hgos-" in text:
        raise ValueError("Unerwartete Calamares-Installationsfolge")
    package_config = r"(?m)^  config:[ \t]+packages_online\.conf[ \t]*$"
    if len(re.findall(package_config, text)) != 1:
        raise ValueError("CachyOS-Paketkonfiguration fehlt")
    text = re.sub(package_config, "  config: packages_hgos.conf", text, count=1)
    instances = (
        "instances:\n"
        "- id: hgos-theme\n  module: shellprocess\n  config: shellprocess_hgos_plymouth.conf\n"
        "- id: hgos\n  module: plymouthcfg\n  config: plymouthcfg_hgos.conf\n"
        "- id: hgos\n  module: netinstall\n  config: netinstall_hgos.conf\n"
        "- id: hgos-branding\n  module: shellprocess\n  config: shellprocess_hgos.conf\n"
    )
    return (text.replace(anchors[0], instances, 1)
            .replace(unmount, "  - shellprocess@hgos-branding\n" + unmount, 1)
            .replace(branding, "branding: hardgamingos\n", 1)
            .replace(plymouth, "  - shellprocess@hgos-theme\n  - plymouthcfg@hgos\n", 1)
            .replace(netinstall, "  - netinstall@hgos\n", 1))


def module_config(modules, filename):
    for directory in (modules, Path("/usr/share/calamares/modules")):
        candidate = directory / filename
        if candidate.is_file():
            return candidate.read_text()
    raise ValueError(f"CachyOS-Moduldatei fehlt: {filename}")


def netinstall_branding(config, groups, local_url):
    config, count = re.subn(r"(?m)^groupsUrl:\n(?:[ \t]+- [^\n]+\n)+",
                            f"groupsUrl:\n - {local_url}\n", config)
    if count != 1:
        raise ValueError("Unbekannte Calamares-Paketquellen")
    remove = (
        "cachyos-hello", "cachyos-kernel-manager", "cachyos-packageinstaller",
        "cachyos-wallpapers", "cachy-update", "cachyos-kde-settings",
        "cachyos-emerald-kde-theme-git", "cachyos-nord-kde-theme-git",
        "cachyos-plymouth-bootanimation", "cachyos-plymouth-theme",
    )
    groups = re.sub(r"(?m)^ +-[ \t]+(?:" + "|".join(remove) + r")[ \t]*\n", "", groups)
    groups = groups.replace('"CachyOS Packages"', '"Systempakete"')
    groups = groups.replace('"CachyOS shell configuration"', '"Shell-Konfiguration"')
    groups = groups.replace('"Shell packages for CachyOS"', '"Optionale Shell-Profile"')
    groups = groups.replace('"needed CachyOS packages"', '"Systempakete und Einstellungen"')
    if "Office & Alltag" not in groups:
        groups = groups.rstrip("\n") + "\n" + OFFICE_GROUP
    return config, groups


IMAGES = "/usr/share/hard-gaming-os/installer"

# Wählbare Gruppe im Installer (seit 2.4.0 eine Edition für Gaming und Alltag).
OFFICE_GROUP = """- name: "Office & Alltag"
  description: "LibreOffice für Dokumente, Tabellen und Präsentationen (deutsch)"
  hidden: false
  selected: true
  critical: false
  packages:
    - libreoffice-fresh
    - libreoffice-fresh-de
"""


def hostname_branding(config):
    """Computername-Vorschlag: hardgaming-<cpu> statt cachyos-<cpu>."""
    if 'template: "hardgaming-' in config:
        return config
    config, count = re.subn(r'(?m)^([ \t]+template:[ \t]*)"cachyos-', r'\1"hardgaming-', config)
    if count != 1:
        print("HGOS Calamares: Hostname-Vorlage nicht gefunden, CachyOS-Vorschlag bleibt", file=sys.stderr)
    return config


def bootloader_branding(config):
    """Bootloader-Vorschaubilder durch HG-Grafiken ersetzen (CachyOS-Logos entfernen)."""
    def image(match):
        name = "grub" if match[2] == "grub" else "generic"
        return f'{match[1]}"{IMAGES}/bootloader-{name}.png"'
    config, count = re.subn(r'(screenshot:[ \t]*)"[^"\n]*/bootloaders/([\w.-]+?)\.(?:jxl|png|webp|jpg)"', image, config)
    if not count and IMAGES not in config:
        print("HGOS Calamares: Bootloader-Bilder nicht gefunden", file=sys.stderr)
    return config


def main():
    p=argparse.ArgumentParser()
    p.add_argument("config",type=Path)
    p.add_argument("--check",action="store_true")
    a=p.parse_args()
    original=a.config.read_text()
    updated=patch(original)
    if not a.check:
        modules = a.config.parent / "modules"
        base = module_config(modules, "packages_online.conf")
        if re.search(r"(?m)^operations[ \t]*:", base):
            raise ValueError("CachyOS-Paketoperationen benötigen erneute Prüfung")
        operations = Path("/usr/share/hard-gaming-os/packages-hgos-operations.conf").read_text()
        groups_file = modules / "netinstall_hgos.yaml"
        netinstall, groups = netinstall_branding(
            module_config(modules, "netinstall.conf"),
            module_config(modules, "netinstall.yaml"), groups_file.as_uri()
        )
        groups_file.write_text(groups)
        users = module_config(modules, "users.conf")
        (modules / "users.conf").write_text(hostname_branding(users))
        chooser = module_config(modules, "packagechooser_bootloader.conf")
        (modules / "packagechooser_bootloader.conf").write_text(bootloader_branding(chooser))
        (modules / "netinstall_hgos.conf").write_text(netinstall)
        (modules / "packages_hgos.conf").write_text(base.rstrip() + "\n\n" + operations)
        a.config.write_text(updated)
    print("HGOS Calamares: Konfiguration geprüft" if a.check else "HGOS Calamares: Branding und Hook aktiviert")

if __name__=="__main__":
    try: main()
    except (ValueError,OSError) as e:
        print(f"HGOS Calamares: {e}",file=sys.stderr)
        sys.exit(1)
