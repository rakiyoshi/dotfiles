source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/environment.zsh"

# Login shells used by editors and scripts get mise shims too.
if [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims" ]]; then
  path=("${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims" $path)
fi
