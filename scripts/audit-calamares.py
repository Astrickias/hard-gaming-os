#!/usr/bin/env python3
"""Read-only verification of staged CachyOS Calamares settings."""
import pathlib,sys,re
if len(sys.argv)!=2: sys.exit('Usage: audit-calamares.py LIVE-ROOT')
root=pathlib.Path(sys.argv[1]).resolve()
if root==pathlib.Path('/'): sys.exit('Refusing /')
errors=[]
for name in ('settings_online.conf','settings_offline.conf'):
 p=root/'usr/share/calamares'/name
 if not p.is_file(): errors.append(f'{name}: missing');continue
 t=p.read_text()
 if not re.search(r'^branding:\s*hardgamingos\s*$',t,re.M): errors.append(f'{name}: HGOS branding missing')
 if name=='settings_online.conf':
  if t.count('shellprocess@hgos')!=1: errors.append('online: HGOS hook missing or duplicated')
  if not re.search(r'(?m)^\s*- shellprocess@hgos\s*\n\s*- umount\s*$',t): errors.append('online: HGOS hook not before umount')
 else:
  if 'shellprocess@hgos' in t: errors.append('offline: hook unexpected')
for f in ('etc/calamares/modules/shellprocess_hgos.conf','usr/local/libexec/hgos-target-hook','usr/share/calamares/branding/hardgamingos/branding.desc'):
 if not (root/f).is_file(): errors.append(f'{f}: missing')
print('Calamares audit:', 'PASS' if not errors else 'FAIL')
for e in errors: print(' -',e)
sys.exit(bool(errors))
