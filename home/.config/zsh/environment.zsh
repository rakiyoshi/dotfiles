typeset -U path PATH
export GOPATH="$HOME/.go"
export DENO_INSTALL="$HOME/.deno"
export LESSCHARSET=utf-8

# Inherited fish/asdf/rbenv paths must not override mise's version selection.
path=(${path:#${HOME}/.asdf/*})
path=(${path:#${HOME}/.rbenv/shims})
path=(
  "$HOME/.local/bin"
  "${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua/bin"
  /opt/nvim-linux-x86_64/bin
  "$GOPATH/bin"
  "$HOME/.cargo/bin"
  "$HOME/.npm-global/bin"
  "$DENO_INSTALL/bin"
  "$HOME/.oci/bin"
  /snap/bin
  $path
)
export AQUA_GLOBAL_CONFIG="$HOME/aqua.yaml:${XDG_CONFIG_HOME:-$HOME/.config}/aquaproj-aqua/aqua.yaml"

if [[ "$OSTYPE" == darwin* && -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
