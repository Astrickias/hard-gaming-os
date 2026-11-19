#!/usr/bin/env python3
"""Validate a pinned Calamares settings file and produce an integration report.
Read-only: does not activate package installation or modify upstream.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

MODULE = re.compile(r"^\s*-\s*(packages(?:@[-\w]+)?|shellprocess@hgos|umount)\s*$", re.M)

def audit(settings, expected_hash, edition, manifest):
    raw = settings.read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    if digest != expected_hash.lower():
        raise ValueError('Upstream SHA256 mismatch: pinned revision required')
    text = raw.decode('utf-8')
    # Restrict to simple, recognized job sequence before interpreting positions.
    if text.count('sequence:') != 1 or text.count('  - umount') != 1:
        raise ValueError('Ambiguous or missing Calamares sequence')
    jobs = MODULE.findall(text)
    packages = [i for i, job in enumerate(jobs) if job.startswith('packages')]
    unmount = [i for i, job in enumerate(jobs) if job == 'umount']
    hook = [i for i, job in enumerate(jobs) if job == 'shellprocess@hgos']
    if len(unmount) != 1 or len(packages) < 1:
        raise ValueError('Cannot confirm packages job before unmount')
    if any(i >= unmount[0] for i in packages):
        raise ValueError('Package job after unmount')
    if hook and (len(hook) != 1 or not max(packages) < hook[0] < unmount[0]):
        raise ValueError('HGOS hook must follow package jobs and precede unmount')
    names = [line.strip() for line in manifest.read_text().splitlines() if line.strip() and not line.lstrip().startswith('#')]
    if not names or len(names) != len(set(names)) or any(not re.fullmatch(r'[A-Za-z0-9@._+\-]+', x) for x in names):
        raise ValueError('Invalid edition package manifest')
    return {'edition':edition,'settings_sha256':digest,'package_jobs':len(packages),'hgos_hook_present':bool(hook),'package_manifest':names,'result':'sequence structurally validated; actual installation NOT verified'}

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--settings',type=Path,required=True)
    p.add_argument('--sha256',required=True)
    p.add_argument('--edition',choices=['gaming'],required=True)
    p.add_argument('--root',type=Path,default=Path(__file__).resolve().parent.parent)
    p.add_argument('--output',type=Path)
    a=p.parse_args()
    result=audit(a.settings,a.sha256,a.edition,a.root/'config/editions'/f'{a.edition}.packages')
    report=json.dumps(result,indent=2,ensure_ascii=False)+'\n'
    if a.output:
        a.output.parent.mkdir(parents=True,exist_ok=True)
        a.output.write_text(report)
    print(report,end='')

if __name__=='__main__':
    try: main()
    except (ValueError,OSError,UnicodeError) as e:
        print(f'FAILED: {e}',file=sys.stderr);sys.exit(1)
