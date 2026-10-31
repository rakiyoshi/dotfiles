# Shared Bash 3.2-compatible helpers for Linux and macOS installers.
dotfiles_load_homebrew() {
  [[ "$(uname -s)" == Darwin ]] || return 0
  local brew_path
  brew_path=$(command -v brew || true)
  if [[ -z "$brew_path" ]]; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
      brew_path=/opt/homebrew/bin/brew
    elif [[ -x /usr/local/bin/brew ]]; then
      brew_path=/usr/local/bin/brew
    fi
  fi
  if [[ -n "$brew_path" ]]; then
    eval "$("$brew_path" shellenv)"
  fi
}

dotfiles_login_shell() {
  case "$(uname -s)" in
    Darwin) dscl . -read "/Users/$(id -un)" UserShell | awk '$1 == "UserShell:" { print $2 }' ;;
    Linux) getent passwd "$(id -un)" | cut -d: -f7 ;;
    *) echo 'Supported platforms: macOS and Linux.' >&2; return 1 ;;
  esac
}

dotfiles_zsh_path() {
  # macOS includes a registered native zsh; avoid requiring Homebrew shell
  # registration or accidentally selecting an Intel/Rosetta installation.
  if [[ "$(uname -s)" == Darwin ]]; then
    printf '%s\n' /bin/zsh
  else
    command -v zsh
  fi
}

dotfiles_change_shell() {
  local zsh_path current_shell
  zsh_path=$(dotfiles_zsh_path)
  current_shell=$(dotfiles_login_shell)
  [[ -n "$current_shell" ]] || { echo 'Could not determine the current login shell.' >&2; return 1; }
  if [[ "$current_shell" != "$zsh_path" ]]; then
    echo "Changing your login shell to $zsh_path (may require your password)."
    chsh -s "$zsh_path"
  fi
}
