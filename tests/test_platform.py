import os
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
BASH = os.environ.get('DOTFILES_TEST_BASH', '/bin/bash')


class PlatformTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.marker = self.root / 'chsh-called'
        self.env = dict(os.environ, HOME=str(self.root),
                        PATH=str(self.bin) + ':' + os.environ['PATH'],
                        XDG_STATE_HOME=str(self.root / 'state'))
        self.stub('id', 'echo testuser')
        self.stub('chsh', 'printf "%s\\n" "$*" > ' + shlex.quote(str(self.marker)))
        self.stub('sysctl', 'echo 0')
        self.stub('brew', 'echo "export DOTFILES_BREW_LOADED=yes"')

    def tearDown(self):
        self.tmp.cleanup()

    def stub(self, name, body):
        p = self.bin / name
        p.write_text('#!/bin/sh\n' + body + '\n')
        p.chmod(0o755)

    def run_helper(self, command):
        return subprocess.run([BASH, '-eu', '-o', 'pipefail', '-c',
                               'source ' + shlex.quote(str(REPO / 'scripts/platform.sh')) + '; ' + command],
                              env=self.env, capture_output=True, text=True)

    def test_mac_changes_login_shell_using_directory_services(self):
        self.stub('uname', 'echo Darwin')
        self.stub('dscl', 'echo "UserShell: /opt/homebrew/bin/fish"')
        self.stub('getent', 'echo Unexpected getent >&2; exit 90')
        result = self.run_helper('dotfiles_change_shell')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.marker.read_text().strip(), '-s /bin/zsh')

    def test_mac_keeps_existing_system_zsh(self):
        self.stub('uname', 'echo Darwin')
        self.stub('dscl', 'echo "UserShell: /bin/zsh"')
        result = self.run_helper('dotfiles_change_shell')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.marker.exists())

    def test_linux_uses_account_database(self):
        self.stub('uname', 'echo Linux')
        self.stub('getent', 'echo "testuser:x:1000:1000::/home/testuser:/usr/bin/fish"')
        self.stub('zsh', 'exit 0')
        result = self.run_helper('dotfiles_change_shell')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.marker.read_text().strip(), '-s ' + str(self.bin / 'zsh'))

    def test_failed_shell_lookup_does_not_change_account(self):
        self.stub('uname', 'echo Darwin')
        self.stub('dscl', 'exit 1')
        result = self.run_helper('dotfiles_change_shell')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.marker.exists())

    def test_homebrew_bootstrap_is_available_before_prerequisite_checks(self):
        self.stub('uname', 'echo Darwin')
        result = self.run_helper('dotfiles_load_homebrew; [[ "$DOTFILES_BREW_LOADED" == yes ]]')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mac_installer_dry_run_with_no_optional_arguments(self):
        self.stub('uname', 'echo Darwin')
        result = subprocess.run([BASH, str(REPO / 'install.sh'), '--dry-run'],
                                env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Link ' + str(self.root / '.zshrc'), result.stdout)
        self.assertFalse((self.root / '.zshrc').exists())

    def test_rosetta_terminal_rejected_before_mutation(self):
        self.stub('uname', 'echo Darwin')
        self.stub('sysctl', 'echo 1')
        result = subprocess.run([BASH, str(REPO / 'install.sh'), '--dry-run'],
                                env=self.env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Rosetta', result.stderr)
        self.assertFalse((self.root / '.zshrc').exists())

    def test_mac_zsh_uses_homebrew_completions_without_linux_paths(self):
        prefix = self.root / 'homebrew'
        (prefix / 'share/zsh/site-functions').mkdir(parents=True)
        exports = 'export HOMEBREW_PREFIX=' + shlex.quote(str(prefix))
        exports += '; export PATH="$HOMEBREW_PREFIX/bin:$PATH"'
        self.stub('brew', 'printf "%s\\n" ' + shlex.quote(exports))
        source = shlex.quote(str(REPO / 'home/.config/zsh/environment.zsh'))
        command = 'OSTYPE=darwin; path=("$TEST_BIN" /usr/bin /bin); source ' + source
        command += '; [[ -n ${path[(r)$TEST_PREFIX/bin]} ]]'
        command += '; [[ -n ${fpath[(r)$TEST_PREFIX/share/zsh/site-functions]} ]]'
        command += '; [[ -z ${path[(r)/snap/bin]} && -z ${path[(r)/opt/nvim-linux-x86_64/bin]} ]]'
        result = subprocess.run([shutil.which('zsh'), '-efc', command],
                                env=dict(self.env, TEST_BIN=str(self.bin), TEST_PREFIX=str(prefix)),
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
