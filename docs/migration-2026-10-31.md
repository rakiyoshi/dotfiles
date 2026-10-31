# WSL migration, 2026-10-31

Configuration was consolidated from the actual local `fish-castle`,
`asdf-castle`, `git-castle`, and `vim-castle` checkouts, preserving local edits
rather than fetching the older remote castle versions. The base repository is
`rakiyoshi/dotfiles`, branch `migrate-zsh-mise`.

The working checkout is `~/.local/share/dotfiles`. The configuration is under
`home/`. No submodules or castle repositories are required for the new setup.
The previous ConEmu configuration is retained.

## Versions

| Tool | mise global version | Decision |
| --- | --- | --- |
| Ruby | 4.0.9 | Owner requested latest; resolved with `mise latest ruby` |
| Python | 3.14.2 | Existing asdf pin |
| Go | 1.24.2 | Existing asdf pin |
| Node.js | 16.13.0 | Existing asdf pin |
| Terraform | 1.1.8 | Existing asdf pin |
| direnv | 2.36.0 | Existing asdf pin |
| Helm | 3.7.1 | Existing asdf pin |
| kubectl | 1.23.1 | Existing asdf pin |

Mise 2026.10.23 and all eight tools have been installed and executed successfully.
The existing Python 3.14 environment's pipx 1.8.0 and its five dependencies were
also installed into the native mise Python environment. Other legacy runtimes,
virtual environments, and Ruby gems are left in place for compatibility.

The existing `~/.config/go/env` requests `GOTOOLCHAIN=go1.25.0+auto`. That local
setting is preserved, so Go may select 1.25.0 even though mise selects the 1.24.2
installation. `GOTOOLCHAIN=local go version` checks the pinned executable.

## Applying the prepared migration

Run in your WSL terminal:

```sh
bash ~/.local/share/dotfiles/install.sh --migrate --change-shell
exec zsh -l
```

This step is required because the Codex sandbox cannot write the home-level
configuration links or run the privileged login-shell change. The installer
backs up displaced files before linking the new configuration. No remote GitHub
repositories are deleted. The old castle checkouts are retained as rollback data;
they are not sourced by the new zsh configuration.

Review the installer's printed backup path before removing any old manager data.
See the main README for the restore command and verification commands.

## Validation

- Installer migration, idempotence, rollback, repeat rollback, and failure rollback
  tested in isolated homes; symlinked parent directories are rejected before mutation.
- Interactive zsh and noninteractive login zsh tested using an isolated Linux home.
- Interactive zsh starts without errors; `mise doctor` reports no problems.
- All eight installed tool executables run successfully.
- Bash and zsh syntax checks pass; Git's whitespace check passes.
- Git and Neovim settings come from the existing local configuration.
- Secrets, credential files, SSH keys, and machine-local configuration are excluded.

The default login shell remains fish until the apply command above succeeds.
