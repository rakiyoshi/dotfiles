import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location('link', Path(__file__).resolve().parents[1] / 'scripts/link.py')
link = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(link)


class LinkMigrationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name) / 'home'
        self.home.mkdir()
        self.env = patch.dict(os.environ, {'HOME': str(self.home), 'XDG_STATE_HOME': str(self.home / '.local/state')})
        self.env.start()

    def tearDown(self):
        self.env.stop()
        self.tmp.cleanup()

    def apply(self):
        with patch('sys.argv', ['link.py', '--migrate']):
            link.main()

    def backups(self):
        return list((self.home / '.local/state/dotfiles/backups').iterdir())

    def test_migrate_idempotence_and_restore(self):
        castle = self.home / '.homesick/repos/git-castle/home'
        castle.mkdir(parents=True)
        (castle / '.gitconfig').write_text('local Git edits\n')
        gitconfig = self.home / '.gitconfig'
        original = '.homesick/repos/git-castle/home/.gitconfig'
        gitconfig.symlink_to(original)
        fish = self.home / '.config/fish'
        fish.mkdir(parents=True)
        (fish / 'config.fish').write_text('local fish edits\n')
        (self.home / '.tool-versions').write_text('ruby 3.0.2\n')
        (self.home / 'aqua.yaml').write_text('packages: []\n')
        (self.home / 'aqua-checksums.json').write_text('{}\n')
        aqua_config = self.home / '.config/aquaproj-aqua'
        aqua_config.mkdir()
        (aqua_config / 'aqua.yaml').write_text('registries: []\n')
        local = self.home / '.gitconfig.local'
        local.write_text('machine settings\n')
        self.apply()
        self.assertEqual(gitconfig.resolve(), link.REPO / 'home/.gitconfig')
        self.assertFalse(fish.exists())
        self.assertFalse((self.home / '.tool-versions').exists())
        self.assertFalse((self.home / 'aqua.yaml').exists())
        self.assertFalse((self.home / 'aqua-checksums.json').exists())
        self.assertFalse((aqua_config / 'aqua.yaml').exists())
        self.assertEqual(local.read_text(), 'machine settings\n')
        backup = self.backups()[0]
        self.assertEqual((backup / 'home/.gitconfig').read_text(), 'local Git edits\n')
        self.apply()
        self.assertEqual(len(self.backups()), 1)
        link.restore(backup)
        self.assertEqual(os.readlink(gitconfig), original)
        self.assertEqual(gitconfig.read_text(), 'local Git edits\n')
        self.assertEqual((fish / 'config.fish').read_text(), 'local fish edits\n')
        self.assertEqual((self.home / '.tool-versions').read_text(), 'ruby 3.0.2\n')
        self.assertEqual((self.home / 'aqua.yaml').read_text(), 'packages: []\n')
        self.assertEqual((self.home / 'aqua-checksums.json').read_text(), '{}\n')
        self.assertEqual((aqua_config / 'aqua.yaml').read_text(), 'registries: []\n')
        self.assertFalse((self.home / '.zshrc').exists())
        link.restore(backup)
        self.assertEqual(gitconfig.read_text(), 'local Git edits\n')

    def test_failed_link_restores_displaced_file(self):
        old = self.home / '.zshrc'
        old.write_text('keep this\n')
        with patch.object(Path, 'symlink_to', side_effect=OSError('simulated failure')):
            with self.assertRaises(OSError):
                self.apply()
        self.assertEqual(old.read_text(), 'keep this\n')

    def test_retired_aqua_link_recovers_snapshot_after_source_removal(self):
        target = self.home / 'aqua.yaml'
        target.symlink_to(link.REPO / 'home/aqua.yaml')
        snapshot = self.home / '.local/state/dotfiles/aqua-retirement/20261031/aqua.yaml'
        snapshot.parent.mkdir(parents=True)
        snapshot.write_text('packages: []\n')
        self.apply()
        backup = self.backups()[0]
        saved = backup / 'home/aqua.yaml'
        self.assertFalse(saved.is_symlink())
        self.assertEqual(saved.read_text(), 'packages: []\n')
        link.restore(backup)
        self.assertFalse(target.is_symlink())
        self.assertEqual(target.read_text(), 'packages: []\n')

    def test_symlinked_parent_rejected_before_mutation(self):
        external = self.home / 'other-config'
        external.mkdir()
        (self.home / '.config').symlink_to(external)
        with self.assertRaisesRegex(RuntimeError, 'symlinked parent'):
            self.apply()
        self.assertFalse((self.home / '.zshrc').exists())
        self.assertEqual(list(external.iterdir()), [])


if __name__ == '__main__':
    unittest.main()
