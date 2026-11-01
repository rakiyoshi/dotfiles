"""Exercise actual ZLE expansion with the complete interactive plugin stack."""
import os
from pathlib import Path
import pty
import select
import shlex
import shutil
import signal
import subprocess
import tempfile
import time
import unittest

REPO = Path(__file__).resolve().parents[1]
PLUGIN_DATA = os.environ.get('DOTFILES_TEST_PLUGIN_DATA')


@unittest.skipUnless(PLUGIN_DATA, 'Set DOTFILES_TEST_PLUGIN_DATA to installed plugin data')
class AbbreviationIntegrationTests(unittest.TestCase):
    def test_space_enter_and_persistent_definitions(self):
        with tempfile.TemporaryDirectory(prefix='dotfiles-abbr-') as tmp:
            home = Path(tmp)
            config = home / '.config'
            config.mkdir()
            (config / 'zsh').symlink_to(REPO / 'home/.config/zsh', target_is_directory=True)
            storage = home / 'user-abbreviations'
            shutil.copyfile(REPO / 'home/.config/zsh/abbreviations', storage)
            (home / '.local/bin').mkdir(parents=True)
            nvim = home / '.local/bin/nvim'
            nvim.write_text('#!/bin/sh\nexit 0\n')
            nvim.chmod(0o755)
            output = home / 'enter-output'
            (home / '.zshenv').write_text('skip_global_compinit=1\n')
            rc = 'source ' + shlex.quote(str(REPO / 'home/.zshrc')) + '\n'
            rc += "PROMPT='ABBR_TEST> '; RPROMPT=''\n"
            rc += "abbr -S --quiet zzabbr='git status'\n"
            rc += "abbr -S --quiet zzrunabbr='print -r -- ok > \"$ABBR_TEST_OUTPUT\"'\n"
            rc += "function capture-test-buffer() { zle -I; print -r -- \"CAPTURE<$BUFFER>\"; BUFFER=''; zle reset-prompt; }\n"
            rc += "zle -N capture-test-buffer\nbindkey '^X' capture-test-buffer\n"
            (home / '.zshrc').write_text(rc)
            env = dict(os.environ, HOME=tmp, XDG_CONFIG_HOME=str(config),
                       XDG_DATA_HOME=PLUGIN_DATA, XDG_CACHE_HOME=str(home / '.cache'),
                       XDG_STATE_HOME=str(home / '.state'), DOTFILES_SSH_AGENT_RELAY='0',
                       ABBR_USER_ABBREVIATIONS_FILE=str(storage), ABBR_TEST_OUTPUT=str(output),
                       TERM='xterm-256color', PATH='/usr/bin:/bin:/usr/local/bin')
            pid, fd = pty.fork()
            if pid == 0:
                os.chdir(tmp)
                os.execve(shutil.which('zsh'), ['zsh', '-il'], env)
            pending = b''

            def expect(marker):
                nonlocal pending
                deadline = time.monotonic() + 20
                wanted = marker.encode()
                while wanted not in pending:
                    remaining = deadline - time.monotonic()
                    if remaining <= 0:
                        self.fail('Missing ' + marker + ': ' + pending.decode(errors='replace'))
                    ready, _, _ = select.select([fd], [], [], remaining)
                    if ready:
                        pending += os.read(fd, 65536)
                _, pending = pending.split(wanted, 1)

            def type_keys(keys):
                # Expansion intentionally skips queued/pasted input. Send
                # human-like key events rather than one paste-sized batch.
                for key in keys:
                    os.write(fd, bytes([key]))
                    time.sleep(0.04)

            try:
                expect('ABBR_TEST> ')
                for short, expanded in [('l', 'ls'), ('ll', 'ls -l'),
                                        ('la', 'ls -la'), ('al', 'ls -la'),
                                        ('cp', 'cp -i'), ('vim', 'nvim')]:
                    type_keys((short + ' \x18').encode())
                    expect('CAPTURE<' + expanded + ' >')
                    expect('ABBR_TEST> ')
                type_keys(b'cp file \x18')
                expect('CAPTURE<cp -i file >')
                expect('ABBR_TEST> ')
                type_keys(b'zzabbr \x18')
                expect('CAPTURE<git status >')
                expect('ABBR_TEST> ')
                type_keys(b'zzrunabbr\r')
                expect('ABBR_TEST> ')
                self.assertEqual(output.read_text().strip(), 'ok')
                os.write(fd, b"abbr --quiet zzsavedabbr='git status --short'; print -r -- PERSIST\"\"DONE\r")
                expect('PERSISTDONE')
                expect('ABBR_TEST> ')
                self.assertIn('zzsavedabbr', storage.read_text())
                type_keys(b'zzsavedabbr \x18')
                expect('CAPTURE<git status --short >')
                self.assertTrue(storage.is_file())
                restarted = subprocess.run(
                    [shutil.which('zsh'), '-ic', 'abbr list'], env=env,
                    cwd=tmp, capture_output=True, text=True, timeout=20)
                self.assertEqual(restarted.returncode, 0, restarted.stderr)
                self.assertIn('zzsavedabbr', restarted.stdout)
            finally:
                os.kill(pid, signal.SIGKILL)
                os.close(fd)
                os.waitpid(pid, 0)
