# dotfiles

One repository for zsh, mise, Git, Vim/Neovim, and Aqua configuration.
No homeshick, castles, asdf shell initialization, rbenv initialization, Prezto,
or shell plugin manager is required. `ConEmu.xml` remains available for Windows.

## Install

On Ubuntu/WSL, install the prerequisites in your terminal:

```sh
sudo apt-get update
sudo apt-get install -y zsh git curl python3
```

Clone this repository anywhere you intend to keep it permanently, then install:

```sh
git clone https://github.com/rakiyoshi/dotfiles.git ~/dotfiles
bash ~/dotfiles/install.sh --change-shell
```

The installer installs mise if needed, installs the pinned tools, links the
configuration from `home/`, and changes the login shell only when requested.
Existing configuration is moved into a timestamped backup under
`~/.local/state/dotfiles/backups/`. Files such as `~/.gitconfig.local`,
`~/.zshrc.local`, and `~/.vimrc_local` remain local and are not overwritten.
Do not run the installer with sudo.

### Migrate the old WSL setup

```sh
bash ~/dotfiles/install.sh --dry-run --migrate
bash ~/dotfiles/install.sh --migrate --change-shell
exec zsh -l
```

`--migrate` also backs up and retires the fish configuration, `~/.tool-versions`,
and `~/.asdfrc`, so the old global asdf settings cannot override mise.
Project `.tool-versions` files continue to work, including `nodejs`/`golang`
aliases; `.ruby-version` and other configured idiomatic version files work too.

The old `~/.homesick`, `~/.asdf`, and `~/.rbenv` directories are retained as
rollback data and to avoid breaking pre-existing Python scripts or environments.
The new configuration does not source these managers. Edit and maintain only
this repository going forward. Do not delete old installations until you have
recreated any environments and packages that refer to their absolute paths.

### Tool versions

Versions live in `home/.config/mise/config.toml`. Ruby was upgraded, at the
owner's request, to the latest stable version resolved on 2026-10-31: **4.0.9**.
The other asdf pins were preserved: Python 3.14.2, Go 1.24.2, Node 16.13.0,
Terraform 1.1.8, direnv 2.36.0, Helm 3.7.1, and kubectl 1.23.1.
Installations are native mise installs, independent of the old asdf runtimes.
Previously installed Ruby gems and Python packages are not automatically copied.

Aqua's existing tool selection is preserved in `home/aqua.yaml`; its additional
configuration file is preserved under `home/.config/aquaproj-aqua/`. mise owns
the overlapping global runtimes (Go and Terraform) because its activation puts
the selected versions before Aqua on PATH. Existing Aqua binaries are reused;
install Aqua separately when setting up a new machine that needs those tools.

To update a global runtime, for example Ruby:

```sh
mise use --global ruby@latest
```

Because `mise use` can replace a config symlink when writing, confirm the change
is in `~/dotfiles/home/.config/mise/config.toml` before committing; edit that file
and run `mise install` directly if you prefer.

## zsh

The shell has completion, shared history, Git branch information, the aliases
from the fish configuration, and mise/direnv activation. Go, Cargo, npm-global,
Deno, Aqua, Neovim, and Codex paths are preserved. Machine settings can be added
to `~/.zshrc.local`; the previous `~/.zshrc_local` spelling is also supported.

On WSL, when `socat` and `npiperelay.exe` are present, `wsl-ssh-agent` reuses or
starts the Windows OpenSSH agent relay. Logs are in
`~/.cache/zsh/ssh-agent-relay.log`. It does not launch a duplicate healthy relay.
The Windows OpenSSH agent and npiperelay must already be configured.
Set `DOTFILES_SSH_AGENT_RELAY=0` to disable relay startup. When Docker Desktop's
system completion symlink is broken, Docker falls back to generic file completion
so `compinit` can still initialize the other installed completions.

Git preserves the current identity, aliases, SSH URL rewrite, and local include.
The GitHub credential helper uses `gh` on PATH instead of a version-specific
absolute Aqua installation path. No credential/token files are stored here.

## Verify

Open a new WSL terminal, then run:

```sh
getent passwd "$(id -un)" | cut -d: -f7
mise doctor
mise ls
ruby --version
python --version
node --version
go version
terraform version
```

## Roll back

The installer prints the exact backup path and restore command:

```sh
python3 ~/dotfiles/scripts/link.py --restore ~/.local/state/dotfiles/backups/TIMESTAMP
chsh -s /usr/bin/fish
```

Rollback restores the previous files and symlink targets, including the fish
configuration. It does not remove mise or the downloaded tools. Keep the old
castle checkouts until you no longer need rollback.

## Development

```sh
python3 -m unittest discover -s tests -v
bash -n install.sh home/.local/bin/wsl-ssh-agent
zsh -n home/.zshrc home/.zprofile home/.zshenv home/.config/zsh/environment.zsh
```
