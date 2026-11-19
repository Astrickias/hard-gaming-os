#!/usr/bin/env python3
"""Patch the staged CachyOS calamares-online.sh without executing it."""
import argparse
from pathlib import Path
import sys

def patch(source):
    needle='exec pkexec-wrapper calamares -D6 >> $log'
    if source.count(needle)!=1 or source.count('sudo cp "/usr/share/calamares/settings_${mode}.conf" /etc/calamares/settings.conf')!=1:
        raise ValueError('Unbekanntes CachyOS-Startskript')
    for line in ('sudo pacman -Sy --noconfirm cachyos-calamares-next',
                 'sudo cp "/usr/share/calamares/settings_${mode}.conf" /etc/calamares/settings.conf'):
        if source.count(line) != 1:
            raise ValueError("Unbekannter Installationsschritt")
        source = source.replace(line, line + ' || exit 1', 1)
    return source.replace(needle, 'sudo /usr/local/libexec/hgos-calamares-libfix || exit 1\n    sudo /usr/local/libexec/hgos-calamares-runtime /etc/calamares/settings.conf || exit 1\n    '+needle,1)

def main():
    p=argparse.ArgumentParser(); p.add_argument('file',type=Path); a=p.parse_args()
    source=a.file.read_text(); updated=patch(source)
    a.file.write_text(updated)

if __name__=='__main__':
    try: main()
    except (ValueError,OSError) as e: print(e,file=sys.stderr); sys.exit(1)
