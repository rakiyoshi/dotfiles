typeset -U path PATH
typeset -U fpath
export GOPATH="$HOME/.go"
export DENO_INSTALL="$HOME/.deno"
export LESSCHARSET=utf-8

# Inherited fish/asdf/rbenv paths must not override mise's version selection.
path=(${path:#${HOME}/.asdf/*})
path=(${path:#${HOME}/.rbenv/shims})
# Remove Aqua paths inherited from an already-running terminal as well.
for _aqua_root in "${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}" \
                  "${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua"; do
  path=(${path:#${_aqua_root}/*})
done
unset AQUA_GLOBAL_CONFIG AQUA_ROOT_DIR _aqua_root

# Homebrew provides bootstrap packages on macOS; mise selects tool versions.
if [[ "$OSTYPE" == darwin* ]]; then
  _dotfiles_brew=${commands[brew]:-}
  [[ -n "$_dotfiles_brew" || ! -x /opt/homebrew/bin/brew ]] || _dotfiles_brew=/opt/homebrew/bin/brew
  [[ -n "$_dotfiles_brew" || ! -x /usr/local/bin/brew ]] || _dotfiles_brew=/usr/local/bin/brew
  if [[ -n "$_dotfiles_brew" ]]; then
    eval "$("$_dotfiles_brew" shellenv)"
    [[ ! -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]] || \
      fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
  fi
  unset _dotfiles_brew
fi
path=(
  "$HOME/.local/bin"
  "$GOPATH/bin"
  "$HOME/.cargo/bin"
  "$HOME/.npm-global/bin"
  "$DENO_INSTALL/bin"
  "$HOME/.oci/bin"
  $path
)
if [[ "$OSTYPE" == linux* ]]; then
  [[ ! -d /snap/bin ]] || path=(/snap/bin $path)
  [[ ! -d /opt/nvim-linux-x86_64/bin ]] || path=(/opt/nvim-linux-x86_64/bin $path)
fi
