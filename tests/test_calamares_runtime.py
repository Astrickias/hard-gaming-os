"""Tests für scripts/hgos-calamares-runtime.py mit verkleinerten CachyOS-Konfigurationen.

Die Beispiele folgen dem Aufbau von CachyOS/cachyos-calamares (Branch cachyos,
geprüft am 19.11.2026). Sie ersetzen keinen Test im Live-System.
"""
import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/hgos-calamares-runtime.py"
spec = importlib.util.spec_from_file_location("runtime", SCRIPT)
runtime = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runtime)

SETTINGS = """---
modules-search: [ local ]
instances:
- id:       online
  module:   packages
  config:   packages_online.conf
sequence:
- show:
  - welcome@online
  - netinstall
  - users
- exec:
  - packages@online
  - plymouthcfg
  - shellprocess@cleanup_calamares
  - umount
- show:
  - finished
branding: cachyos
"""

NETINSTALL_CONF = """---
groupsUrl:
 - https://raw.githubusercontent.com/CachyOS/cachyos-calamares/cachyos/src/modules/netinstall/netinstall.yaml
 - file:///etc/calamares/modules/netinstall.yaml
required: false
"""

GROUPS = """- name: "CachyOS Packages"
  description: "needed CachyOS packages"
  hidden: false
  selected: true
  critical: true
  packages:
     - cachyos-hooks
     - cachyos-hello
     - cachyos-wallpapers
- name: "Plymouth"
  description: "Splash screen on boot"
  hidden: false
  selected: true
  critical: true
  packages:
    - plymouth
    - cachyos-plymouth-bootanimation
    - cachyos-plymouth-theme
"""

USERS = """hostname:
  location: EtcFile
  writeHostsFile: true
  template: "cachyos-${cpu}"
  forbidden_names: [ localhost ]
"""

CHOOSER = """items:
    - id: grub
      name: "GRUB"
      screenshot: "/etc/calamares/images/bootloaders/grub.jxl"
    - id: limine
      name: "Limine"
      screenshot: "/etc/calamares/images/bootloaders/limine.jxl"
"""


class Runtime(unittest.TestCase):
    def test_settings_sequence(self):
        out = runtime.patch(SETTINGS.replace("  config:   packages_online.conf", "  config:   packages_online.conf"))
        self.assertIn("branding: hardgamingos", out)
        self.assertIn("  - netinstall@hgos", out)
        self.assertLess(out.index("shellprocess@hgos-theme"), out.index("plymouthcfg@hgos"))
        self.assertLess(out.index("shellprocess@hgos-branding"), out.index("  - umount"))
        self.assertIn("config: packages_hgos.conf", out)
        with self.assertRaises(ValueError):
            runtime.patch(out)  # zweimal anwenden ist nicht erlaubt

    def test_netinstall_branding_and_office(self):
        conf, groups = runtime.netinstall_branding(NETINSTALL_CONF, GROUPS, "file:///etc/calamares/modules/netinstall_hgos.yaml")
        self.assertIn("file:///etc/calamares/modules/netinstall_hgos.yaml", conf)
        self.assertNotIn("raw.githubusercontent.com", conf)
        for gone in ("cachyos-hello", "cachyos-wallpapers", "cachyos-plymouth-theme", "cachyos-plymouth-bootanimation"):
            self.assertNotIn(gone, groups)
        self.assertIn("cachyos-hooks", groups)
        self.assertIn('"Systempakete"', groups)
        self.assertEqual(groups.count('- name: "Office & Alltag"'), 1)
        self.assertIn("libreoffice-fresh-de", groups)
        _, again = runtime.netinstall_branding(NETINSTALL_CONF, groups, "file:///x.yaml")
        self.assertEqual(again.count("Office & Alltag"), 1)

    def test_hostname(self):
        out = runtime.hostname_branding(USERS)
        self.assertIn('template: "hardgaming-${cpu}"', out)
        self.assertEqual(runtime.hostname_branding(out), out)

    def test_bootloader_images(self):
        out = runtime.bootloader_branding(CHOOSER)
        self.assertIn("/usr/share/hard-gaming-os/installer/bootloader-grub.png", out)
        self.assertIn("/usr/share/hard-gaming-os/installer/bootloader-generic.png", out)
        self.assertNotIn(".jxl", out)


if __name__ == "__main__":
    unittest.main()
