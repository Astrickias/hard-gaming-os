"""Prüft stage-live-branding.py gegen ein nachgebautes, minimales CachyOS-Profil.

Die Struktur ist dem archiso-/CachyOS-Aufbau nachempfunden (GRUB mit Standard-,
LTS- und nomodeset-Eintrag, Syslinux mit LABEL-Blöcken). Sie ersetzt keinen Test
gegen den echten Upstream-Commit.
"""
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SCRIPT = ROOT / "scripts/stage-live-branding.py"

GRUB = '''insmod all_video
if loadfont "${prefix}/fonts/unicode.pf2" ; then
    set gfxmode="auto"
    terminal_output gfxterm
fi

menuentry "CachyOS (linux-cachyos)" --class arch --id 'cachyos' {
    set gfxpayload=keep
    linux /arch/boot/x86_64/vmlinuz-linux-cachyos archisobasedir=arch archisosearchuuid=%ARCHISO_UUID% cow_spacesize=10G
    initrd /arch/boot/x86_64/initramfs-linux-cachyos.img
}

menuentry "CachyOS (linux-cachyos-lts)" --class arch --id 'cachyos-lts' {
    set gfxpayload=keep
    linux /arch/boot/x86_64/vmlinuz-linux-cachyos-lts archisobasedir=arch archisosearchuuid=%ARCHISO_UUID%
    initrd /arch/boot/x86_64/initramfs-linux-cachyos-lts.img
}

menuentry "CachyOS (nomodeset)" --class arch {
    linux /arch/boot/x86_64/vmlinuz-linux-cachyos archisobasedir=arch nomodeset
    initrd /arch/boot/x86_64/initramfs-linux-cachyos.img
}
'''

SYSLINUX = '''LABEL arch64
TEXT HELP
Boot CachyOS
ENDTEXT
MENU LABEL CachyOS (x86_64, BIOS)
MENU DEFAULT
LINUX /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux-cachyos
INITRD /%INSTALL_DIR%/boot/x86_64/initramfs-linux-cachyos.img
APPEND archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL%

LABEL arch64lts
MENU LABEL CachyOS LTS (x86_64, BIOS)
LINUX /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux-cachyos-lts
INITRD /%INSTALL_DIR%/boot/x86_64/initramfs-linux-cachyos-lts.img
APPEND archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL%

LABEL arch64nomodeset
MENU LABEL CachyOS nomodeset (x86_64, BIOS)
LINUX /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux-cachyos
INITRD /%INSTALL_DIR%/boot/x86_64/initramfs-linux-cachyos.img
APPEND archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL% nomodeset
'''


def make_stage(base, with_login=True):
    profile = base / "archiso"
    for sub in ("grub", "syslinux", "airootfs/etc/mkinitcpio.conf.d"):
        (profile / sub).mkdir(parents=True)
    (profile / "grub/grub.cfg").write_text(GRUB)
    (profile / "syslinux/archiso_sys-linux.cfg").write_text(SYSLINUX)
    (profile / "profiledef.sh").write_text(
        'iso_name="cachyos"\niso_label="COS_$(date +%Y%m)"\n'
        'iso_publisher="CachyOS <https://cachyos.org>"\n'
        'iso_application="CachyOS Live/Rescue DVD"\nfile_permissions=(\n)\n')
    (base / "util-iso.sh").write_text(
        "x() {\n    cat << 'EOF' > ${src_dir}/archiso/airootfs/etc/motd\nWelcome to CachyOS\nEOF\n}\n")
    (profile / "airootfs/etc/mkinitcpio.conf.d/archiso.conf").write_text(
        "HOOKS=(base udev microcode modconf kms memdisk archiso block filesystems keyboard)\n")
    if with_login:
        (profile / "airootfs/etc/plasmalogin.conf").write_text("[Autologin]\nUser=liveuser\nSession=plasma\n")
    return profile


class StageLiveBranding(unittest.TestCase):
    def setUp(self):
        self.tmp = Path(tempfile.mkdtemp())

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def run_script(self, edition="gaming"):
        return subprocess.run([sys.executable, str(SCRIPT), str(self.tmp), edition],
                              capture_output=True, text=True)

    def test_diagnosis_entries(self):
        profile = make_stage(self.tmp)
        result = self.run_script()
        self.assertEqual(result.returncode, 0, result.stderr)
        grub = (profile / "grub/grub.cfg").read_text()
        # Standard + LTS bekommen je einen Diagnoseeintrag, nomodeset nicht.
        self.assertEqual(grub.count("(Diagnose: seriell, ohne Splash)"), 2)
        self.assertEqual(grub.count("menuentry "), 5)
        self.assertIn("--id 'cachyos-hgosdiag'", grub)
        self.assertIn("--id 'cachyos-lts-hgosdiag'", grub)
        self.assertEqual(grub.count("{"), grub.count("}"))
        diag_lines = [l for l in grub.splitlines() if "ttyS0" in l]
        self.assertEqual(len(diag_lines), 2)
        for line in diag_lines:
            self.assertNotIn(" quiet", line)
            self.assertNotIn(" splash", line)
            self.assertIn("plymouth.enable=0", line)
        self.assertIn("vmlinuz-linux-cachyos-lts", " ".join(diag_lines))
        regular = [l for l in grub.splitlines() if l.strip().startswith("linux ") and "ttyS0" not in l]
        self.assertTrue(all(("quiet splash" in l) != ("nomodeset" in l) for l in regular))
        self.assertIn("Hard Gaming OS Gaming Edition", grub)

        sys_cfg = (profile / "syslinux/archiso_sys-linux.cfg").read_text()
        self.assertIn("LABEL arch64_hgosdiag", sys_cfg)
        self.assertIn("LABEL arch64lts_hgosdiag", sys_cfg)
        self.assertEqual(sys_cfg.count("MENU DEFAULT"), 1)
        self.assertEqual(sys_cfg.count("ttyS0"), 2)
        self.assertNotIn("CachyOS", sys_cfg)
        for block in sys_cfg.split("\n\n"):
            if "_hgosdiag" in block:
                self.assertNotIn(" splash", block)

        self.assertIn("udev plymouth microcode",
                      (profile / "airootfs/etc/mkinitcpio.conf.d/archiso.conf").read_text())
        self.assertIn('iso_label="HGOS_GAMING_', (profile / "profiledef.sh").read_text())
        login = (profile / "airootfs/etc/plasmalogin.conf").read_text()
        self.assertIn("User=liveuser", login)
        self.assertIn("wallpaper-default.jpg", login)

    def test_missing_plasmalogin_fails(self):
        make_stage(self.tmp, with_login=False)
        result = self.run_script("allround")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("plasmalogin.conf fehlt", result.stderr)


if __name__ == "__main__":
    unittest.main()
