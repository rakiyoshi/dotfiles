#!/usr/bin/env bash
set -euo pipefail
repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
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
      echo '  --migrate       Back up and retire fish config, ~/.tool-versions, and ~/.asdfrc.'
      echo '  --change-shell  Change the login shell after linking and checking zsh.'
      echo '  --link-only     Skip mise installation and tool installation.'
      echo '  --dry-run       Show configuration changes without writing anything.'
      exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done
command -v python3 >/dev/null || { echo 'Install Python 3 first.' >&2; exit 1; }
command -v zsh >/dev/null || { echo 'Install zsh first: sudo apt-get install zsh' >&2; exit 1; }
link_args=()
$migrate && link_args+=(--migrate)
if $dry_run; then
  python3 "$repo/scripts/link.py" --dry-run "${link_args[@]}"
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
python3 "$repo/scripts/link.py" "${link_args[@]}"
if ! $link_only; then
  mise trust "$repo/home/.config/mise/config.toml"
  mise reshim
fi
zsh -n "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zshenv" "$HOME/.config/zsh/environment.zsh"
if $change_shell; then
  zsh_path=$(command -v zsh)
  if [[ "$(getent passwd "$(id -un)" | cut -d: -f7)" != "$zsh_path" ]]; then
    echo "Changing your login shell to $zsh_path (may require your password)."
    chsh -s "$zsh_path"
  fi
fi
echo 'Configuration linked. Open a new WSL terminal or run: exec zsh -l'
