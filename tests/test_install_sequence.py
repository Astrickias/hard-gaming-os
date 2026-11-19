import hashlib
import importlib.util
import tempfile
from pathlib import Path
import unittest

SCRIPT=Path(__file__).resolve().parents[1]/'scripts/validate-install-sequence.py'
spec=importlib.util.spec_from_file_location('validator',SCRIPT)
mod=importlib.util.module_from_spec(spec);spec.loader.exec_module(mod)

class SequenceTests(unittest.TestCase):
    def test_both_editions_and_bad_hash(self):
        with tempfile.TemporaryDirectory() as temp:
            settings=Path(temp)/'settings.conf'
            settings.write_text('sequence:\n  - packages\n  - shellprocess@hgos\n  - umount\n')
            sha=hashlib.sha256(settings.read_bytes()).hexdigest()
            for edition in ('gaming','allround'):
                manifest=SCRIPT.parents[1]/'config/editions'/f'{edition}.packages'
                self.assertTrue(mod.audit(settings,sha,edition,manifest)['hgos_hook_present'])
                with self.assertRaises(ValueError):mod.audit(settings,'0'*64,edition,manifest)
    def test_invalid_order(self):
        with tempfile.TemporaryDirectory() as temp:
            settings=Path(temp)/'settings.conf'
            settings.write_text('sequence:\n  - shellprocess@hgos\n  - packages\n  - umount\n')
            sha=hashlib.sha256(settings.read_bytes()).hexdigest()
            with self.assertRaises(ValueError):mod.audit(settings,sha,'gaming',SCRIPT.parents[1]/'config/editions/gaming.packages')

if __name__=='__main__':unittest.main()
