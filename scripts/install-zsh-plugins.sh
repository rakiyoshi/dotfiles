#!/usr/bin/env bash
# Pinned upstream source archives; no extra Git repositories or plugin manager.
set -euo pipefail
# Completion directories must not inherit a group-writable caller umask.
umask 022
root="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$root"

install_plugin() {
  local name=$1 revision=$2 checksum=$3 entrypoint=$4
  local parent="$root/$name" target="$root/$name/$revision" temporary
  local repository=${5:-zsh-users/$name} archive_url=${6:-}
  archive_url=${archive_url:-https://codeload.github.com/$repository/tar.gz/$revision}
  mkdir -p "$parent"
  if [[ ! -r "$target/$entrypoint" ]]; then
    temporary=$(mktemp -d "$parent/.install.XXXXXX")
    # Each plugin installs in a subshell so its cleanup trap stays isolated.
    trap 'rm -rf -- "$temporary"' EXIT
    curl -fsSL "$archive_url" \
      -o "$temporary/source.tar.gz"
    # Python is already a bootstrap prerequisite. Avoid GNU/BSD checksum
    # utility differences, including macOS sha256sum shims without long flags.
    python3 - "$checksum" "$temporary/source.tar.gz" <<'PY'
import hashlib
import sys

digest = hashlib.sha256()
with open(sys.argv[2], 'rb') as archive:
    for chunk in iter(lambda: archive.read(1024 * 1024), b''):
        digest.update(chunk)
if digest.hexdigest() != sys.argv[1]:
    raise SystemExit('Plugin archive checksum mismatch: ' + sys.argv[2])
PY
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

# zsh-abbr v6.5.2 references this exact helper revision as a Git submodule.
# Install it explicitly: even the published release archive omits its contents.
queue_revision=9e9908225935f2f60d7d41947eb04f3af3c749fe
(install_plugin zsh-job-queue "$queue_revision" \
  99f5726e0de4762c27d3f6abba61eac2867ccf0b7412a344b9e948289e1e4e58 \
  zsh-job-queue.zsh olets/zsh-job-queue)
(install_plugin zsh-abbr v6.5.2 \
  d95514604e5466a047ecce504459aa418997a6a24af99455294a9181b1833d98 \
  zsh-abbr.zsh olets/zsh-abbr \
  https://github.com/olets/zsh-abbr/releases/download/v6.5.2/v6.5.2.tar.gz)
dependency="$root/zsh-abbr/v6.5.2/zsh-job-queue"
if [[ -d "$dependency" && ! -L "$dependency" ]]; then
  # Only remove the empty submodule placeholder; never replace unknown files.
  rmdir -- "$dependency"
fi
ln -sfn -- "$root/zsh-job-queue/$queue_revision" "$dependency"
