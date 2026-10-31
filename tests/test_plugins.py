import os
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]


class PluginInstallerTests(unittest.TestCase):
    def test_bad_archive_is_rejected_before_extraction(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            commands = root / 'commands'
            commands.mkdir()
            curl = commands / 'curl'
            curl.write_text('#!/bin/sh\nfor arg; do destination=$arg; done\nprintf corrupt > "$destination"\n')
            curl.chmod(0o755)
            env = dict(os.environ, HOME=tmp, XDG_DATA_HOME=str(root / 'data'),
                       PATH=str(commands) + ':' + os.environ['PATH'])
            result = subprocess.run([os.environ.get('DOTFILES_TEST_BASH', '/bin/bash'),
                                     str(REPO / 'scripts/install-zsh-plugins.sh')],
                                    env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('checksum mismatch', result.stderr)
            plugins = root / 'data/zsh/plugins'
            self.assertEqual(list(plugins.glob('*/current')), [])
            self.assertEqual(list(plugins.glob('*/.install.*')), [])


if __name__ == '__main__':
    unittest.main()
