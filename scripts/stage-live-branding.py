#!/usr/bin/env python3
"""Apply visible Hard Gaming branding to the staged CachyOS profile."""
import argparse
from pathlib import Path
import re
import shutil


def replace_once(path, old, new):
    source = path.read_text()
    if source.count(old) != 1:
        raise ValueError(f"Unbekannte Upstream-Struktur: {path.name}")
    path.write_text(source.replace(old, new, 1))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("stage", type=Path)
    parser.add_argument("edition", choices=("gaming", "allround"))
    args = parser.parse_args()
    stage = args.stage
    profile = stage / "archiso"
    assets = Path(__file__).resolve().parent.parent / "branding/full"
    edition = args.edition.title() + " Edition"
    name = f"Hard Gaming OS {edition}"
    for path in (profile / "grub").glob("*.cfg"):
        source = path.read_text()
        source, count = re.subn(r'(?m)^(menuentry "[^"\n]*)CachyOS', rf'\g<1>{name}', source)
        if not count:
            raise ValueError(f"GRUB-Menü fehlt: {path.name}")
        if path.name == "grub.cfg":
            anchor = "    terminal_output gfxterm\n"
            if source.count(anchor) != 1:
                raise ValueError("GRUB-Grafikausgabe fehlt")
            source = source.replace(anchor, anchor + '    background_color "#101b16"\n')
        source = re.sub(r"(?m)^([ \t]+linux [^\n]+)$",
                        lambda match: match[1] if "nomodeset" in match[1] else match[1] + " quiet splash",
                        source)
        path.write_text(source)
    for path in (profile / "syslinux").glob("*.cfg"):
        source = path.read_text().replace("CachyOS", name)
        if path.name == "archiso_sys-linux.cfg":
            source = re.sub(r"(?m)^(APPEND [^\n]+)$",
                            lambda match: match[1] if "nomodeset" in match[1] else match[1] + " quiet splash",
                            source)
        path.write_text(source)
    shutil.copyfile(assets / "boot-background.png", profile / "syslinux/splash.png")
    (profile / "grub/splash.png").unlink(missing_ok=True)
    (profile / "syslinux/splash1.png").unlink(missing_ok=True)
    profiledef = profile / "profiledef.sh"
    replace_once(profiledef, 'iso_publisher="CachyOS <https://cachyos.org>"',
                 'iso_publisher="Hard Gaming Labs <https://hardgaming.net/>"')
    replace_once(profiledef, 'iso_label="COS_', 'iso_label="HGOS_' + args.edition.upper() + '_')
    replace_once(profiledef, 'iso_application="CachyOS Live/Rescue DVD"',
                 f'iso_application="{name}"')
    util = stage / "util-iso.sh"
    source = util.read_text()
    start = source.index("    cat << 'EOF' > ${src_dir}/archiso/airootfs/etc/motd")
    end = source.index("\nEOF\n", start)
    util.write_text(source[:start] +
                    "    cat << 'EOF' > ${src_dir}/archiso/airootfs/etc/motd\n" +
                    f"Willkommen bei {name}.\nhttps://hardgaming.net/\n" +
                    "Upstream-Quellen: https://github.com/CachyOS/CachyOS-Live-ISO" +
                    source[end:])
    hooks = profile / "airootfs/etc/mkinitcpio.conf.d/archiso.conf"
    replace_once(hooks, " udev microcode ", " udev plymouth microcode ")
    login = profile / "airootfs/etc/plasmalogin.conf"
    with login.open("a") as config:
        config.write("\n" + (assets / "plasma-login.conf").read_text())


if __name__ == "__main__":
    main()
