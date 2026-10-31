#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
source "$repo/scripts/platform.sh"
migrate=false
change_shell=false
link_only=false
dry_run=false
for arg in "$@"; do
  case "$arg" in
    --migrate) migrate=true ;;
    --change-shell) change_shell=true ;;
    --link-only) link_only=true ;;
    --dry-run) dry_run=true ;;
    -h|--help)
      echo 'Usage: bash install.sh [--migrate] [--change-shell] [--link-only] [--dry-run]'
      echo '  --migrate       Back up and retire fish, asdf, and legacy Aqua configuration.'
      echo '  --change-shell  Change the login shell after linking and checking zsh.'
      echo '  --link-only     Skip mise installation and tool installation.'
      echo '  --dry-run       Show configuration changes without writing anything.'
      exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done
case "$(uname -s)" in
  Darwin)
    if [[ "$(sysctl -in sysctl.proc_translated 2>/dev/null || true)" == 1 ]]; then
      echo 'Open a native Apple Silicon terminal instead of a Rosetta terminal, then retry.' >&2
      exit 1
    fi
    dotfiles_load_homebrew
    prerequisites='Install prerequisites with Homebrew: brew install python neovim git-lfs'
    ;;
  Linux) prerequisites='Install prerequisites: sudo apt-get install zsh git curl python3' ;;
  *) echo 'Supported platforms: macOS and Linux.' >&2; exit 1 ;;
esac
for dependency in python3 zsh git curl tar; do
  command -v "$dependency" >/dev/null || { echo "Missing $dependency. $prerequisites" >&2; exit 1; }
done
# Empty arrays with `set -u` fail in macOS's /bin/bash 3.2. Positional
# arguments safely represent zero options on every supported Bash version.
set --
$migrate && set -- "$@" --migrate
if $dry_run; then
  python3 "$repo/scripts/link.py" --dry-run "$@"
  exit 0
fi
export PATH="$HOME/.local/bin:$PATH"
if ! $link_only; then
  if ! command -v mise >/dev/null; then
    installer=$(mktemp)
    trap 'rm -f -- "$installer"' EXIT
    curl -fsSL https://mise.run -o "$installer"
    MISE_INSTALL_PATH="$HOME/.local/bin/mise" sh "$installer"
    rm -f -- "$installer"
    trap - EXIT
  fi
  export GOPATH="${GOPATH:-$HOME/.go}"
  MISE_GLOBAL_CONFIG_FILE="$repo/home/.config/mise/config.toml" mise -C "$repo" install
  bash "$repo/scripts/install-zsh-plugins.sh"
fi
python3 "$repo/scripts/link.py" "$@"
if ! $link_only; then
  mise trust "$repo/home/.config/mise/config.toml"
  mise reshim
fi
for script in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.config/zsh/environment.zsh"; do
  zsh -n "$script"
done
if $change_shell; then
  dotfiles_change_shell
fi
echo 'Configuration linked. Open a new terminal or run: exec zsh -l'
