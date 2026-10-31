#!/usr/bin/env bash
# Pinned upstream source archives; no extra Git repositories or plugin manager.
set -euo pipefail
root="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$root"

install_plugin() {
  local name=$1 revision=$2 checksum=$3 entrypoint=$4
  local parent="$root/$name" target="$root/$name/$revision" temporary
  mkdir -p "$parent"
  if [[ ! -r "$target/$entrypoint" ]]; then
    temporary=$(mktemp -d "$parent/.install.XXXXXX")
    # Each plugin installs in a subshell so its cleanup trap stays isolated.
    trap 'rm -rf -- "$temporary"' EXIT
    curl -fsSL "https://codeload.github.com/zsh-users/$name/tar.gz/$revision" \
      -o "$temporary/source.tar.gz"
    if command -v sha256sum >/dev/null; then
      printf '%s  %s\n' "$checksum" "$temporary/source.tar.gz" | sha256sum --check --status
    else
      printf '%s  %s\n' "$checksum" "$temporary/source.tar.gz" | shasum -a 256 --check --status
    fi
    mkdir "$temporary/source"
    tar -xzf "$temporary/source.tar.gz" -C "$temporary/source" --strip-components=1
    [[ -r "$temporary/source/$entrypoint" ]]
    mv -- "$temporary/source" "$target"
    rm -rf -- "$temporary"
    trap - EXIT
  fi
  if [[ -e "$parent/current" && ! -L "$parent/current" ]]; then
    echo "Refusing to replace non-symlink: $parent/current" >&2
    exit 1
  fi
  ln -sfn -- "$revision" "$parent/current"
  echo "Installed $name ($revision)"
}

(install_plugin zsh-autosuggestions \
  e52ee8ca55bcc56a17c828767a3f98f22a68d4eb \
  166fad9326c99904fd3b16b5d770efb4f5df39a674599e72bba8fc41636ab065 \
  zsh-autosuggestions.zsh)
(install_plugin zsh-syntax-highlighting \
  db085e4661f6aafd24e5acb5b2e17e4dd5dddf3e \
  874999413d147b7ad6776077e1b756d31d68284f9ef2ef240b33a4c842f0e1d8 \
  zsh-syntax-highlighting.zsh)
