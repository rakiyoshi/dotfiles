typeset -U path PATH
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
path=(
  "$HOME/.local/bin"
  /opt/nvim-linux-x86_64/bin
  "$GOPATH/bin"
  "$HOME/.cargo/bin"
  "$HOME/.npm-global/bin"
  "$DENO_INSTALL/bin"
  "$HOME/.oci/bin"
  /snap/bin
  $path
)

if [[ "$OSTYPE" == darwin* && -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
