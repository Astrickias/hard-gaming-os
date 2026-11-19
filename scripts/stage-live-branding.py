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


DIAG_SUFFIX = " (Diagnose: seriell, ohne Splash)"
DIAG_PARAMS = ("console=tty0 console=ttyS0,115200n8 plymouth.enable=0 loglevel=7 "
               "systemd.show_status=1 systemd.log_target=console rd.udev.log_level=info")


def diag_params(line):
    """Turn a regular kernel line into a diagnosis line: no splash, serial console."""
    line = re.sub(r"[ \t]+(quiet|splash)(?=[ \t]|$)", "", line)
    return line + " " + DIAG_PARAMS


def grub_blocks(source):
    """Yield (start, end) of each top-level menuentry block by counting braces."""
    for match in re.finditer(r'(?m)^[ \t]*menuentry "', source):
        depth, index = 0, match.start()
        while index < len(source):
            char = source[index]
            if char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    end = source.find("\n", index)
                    yield match.start(), (len(source) if end < 0 else end + 1)
                    break
            index += 1


def add_grub_diagnosis(source):
    """Duplicate every splash entry (Standard- und LTS-Kernel) as a diagnosis entry."""
    out, last, count = [], 0, 0
    for start, end in list(grub_blocks(source)):
        block = source[start:end]
        if not re.search(r"(?m)^[ \t]+linux [^\n]* splash\b", block):
            continue
        diag = re.sub(r'^([ \t]*menuentry "[^"\n]*)"', lambda m: m[1] + DIAG_SUFFIX + '"', block, count=1)
        diag = re.sub(r"(?m)^([ \t]+linux [^\n]+)$", lambda m: diag_params(m[1]), diag)
        diag = re.sub(r"(--id[ =]['\"]?)([\w.-]+)", r"\1\2-hgosdiag", diag)
        out.append(source[last:end] + diag)
        last, count = end, count + 1
    out.append(source[last:])
    return "".join(out), count


def add_syslinux_diagnosis(source):
    """Duplicate every LABEL block with a splash APPEND line as a diagnosis entry."""
    parts = re.split(r"(?m)^(?=LABEL )", source)
    out, count = [], 0
    for part in parts:
        out.append(part)
        if part.startswith("LABEL ") and re.search(r"(?m)^APPEND [^\n]* splash\b", part):
            diag = re.sub(r"^LABEL (\S+)", r"LABEL \1_hgosdiag", part, count=1)
            diag = re.sub(r"(?m)^(MENU LABEL [^\n]+)$", lambda m: m[1] + DIAG_SUFFIX, diag, count=1)
            diag = re.sub(r"(?m)^(APPEND [^\n]+)$", lambda m: diag_params(m[1]), diag)
            diag = re.sub(r"(?m)^MENU DEFAULT\n", "", diag)
            if not diag.endswith("\n\n"):
                diag = diag.rstrip("\n") + "\n\n"
            if not out[-1].endswith("\n\n"):
                out[-1] = out[-1].rstrip("\n") + "\n\n"
            out.append(diag)
            count += 1
    return "".join(out), count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("stage", type=Path)
    parser.add_argument("edition", choices=("gaming",))
    args = parser.parse_args()
    stage = args.stage
    profile = stage / "archiso"
    assets = Path(__file__).resolve().parent.parent / "branding/full"
    name = "Hard Gaming OS"  # seit 2.3.0 eine Edition
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
        if path.name == "grub.cfg":
            source, count = add_grub_diagnosis(source)
            if not count:
                raise ValueError("GRUB-Diagnoseeintrag konnte nicht erzeugt werden")
        path.write_text(source)
    for path in (profile / "syslinux").glob("*.cfg"):
        source = path.read_text().replace("CachyOS", name)
        if path.name == "archiso_sys-linux.cfg":
            source = re.sub(r"(?m)^(APPEND [^\n]+)$",
                            lambda match: match[1] if "nomodeset" in match[1] else match[1] + " quiet splash",
                            source)
            source, count = add_syslinux_diagnosis(source)
            if not count:
                raise ValueError("Syslinux-Diagnoseeintrag konnte nicht erzeugt werden")
        path.write_text(source)
    shutil.copyfile(assets / "boot-background.png", profile / "syslinux/splash.png")
    (profile / "grub/splash.png").unlink(missing_ok=True)
    (profile / "syslinux/splash1.png").unlink(missing_ok=True)
    profiledef = profile / "profiledef.sh"
    replace_once(profiledef, 'iso_publisher="CachyOS <https://cachyos.org>"',
                 'iso_publisher="Hard Gaming Labs <https://hardgaming.net/>"')
    replace_once(profiledef, 'iso_label="COS_', 'iso_label="HGOS_')
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
    if not login.is_file():
        # Früher legte "open('a')" die Datei still neu an – ohne die Autologin-Sektion
        # des Upstream-Profils. Fehlt sie, ist der Live-Login ungeklärt: Abbruch.
        raise ValueError("Upstream-plasmalogin.conf fehlt: Live-Autologin ungeklärt")
    with login.open("a") as config:
        config.write("\n" + (assets / "plasma-login.conf").read_text())


if __name__ == "__main__":
    main()
