#!/usr/bin/env python3
"""Link the single repository into HOME; journal backups for rollback."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import sys

REPO = Path(__file__).resolve().parents[1]
MANAGED = [
    '.zshrc', '.zprofile', '.zshenv', '.gitconfig', '.vimrc', '.agignore',
    '.gitignore_global', 'aqua.yaml', 'aqua-checksums.json',
    '.config/zsh', '.config/mise/config.toml', '.config/git/ignore',
    '.config/nvim', '.config/aquaproj-aqua/aqua.yaml',
    '.config/starship.toml',
    '.local/bin/wsl-ssh-agent',
]
RETIRED = ['.config/fish', '.tool-versions', '.asdfrc']


def exists(path):
    return path.exists() or path.is_symlink()


def remove(path):
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.exists():
        shutil.rmtree(path)


def restore(backup):
    metadata = json.loads((backup / 'manifest.json').read_text())
    if metadata.get('restored'):
        print('This backup has already been restored:', backup)
        return
    home = Path(metadata['home'])
    for item in reversed(metadata['changes']):
        target = home / item['path']
        remove(target)
        saved = backup / 'home' / item['path']
        if exists(saved):
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(saved), str(target))
            if 'original_symlink' in item:
                target.unlink()
                target.symlink_to(item['original_symlink'])
    metadata['restored'] = True
    (backup / 'manifest.json').write_text(json.dumps(metadata, indent=2) + '\n')
    print('Restored configuration from', backup)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--migrate', action='store_true')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--restore', type=Path)
    args = parser.parse_args()
    if args.restore:
        restore(args.restore.resolve())
        return
    home = Path.home()
    changes = []
    for name in MANAGED:
        source = REPO / 'home' / name
        target = home / name
        if not source.exists():
            raise RuntimeError('Missing source: ' + str(source))
        if target.is_symlink() and target.resolve() == source.resolve():
            continue
        changes.append({'path': name, 'source': str(source)})
    if args.migrate:
        changes += [{'path': name, 'source': None} for name in RETIRED if exists(home / name)]
    # Do not write through a directory symlink into a different castle.
    for item in changes:
        parent = (home / item['path']).parent
        while parent != home:
            if parent.is_symlink():
                raise RuntimeError('Refusing symlinked parent: ' + str(parent))
            parent = parent.parent
    for item in changes:
        print(('Link ' if item['source'] else 'Retire ') + str(home / item['path']))
    if args.dry_run or not changes:
        if not changes:
            print('All configuration links are current.')
        return
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
    state = Path(os.environ.get('XDG_STATE_HOME', home / '.local/state'))
    backup = state / 'dotfiles' / 'backups' / stamp
    backup.mkdir(parents=True, mode=0o700)
    metadata = {'home': str(home), 'repository': str(REPO), 'changes': []}
    journal = backup / 'manifest.json'
    try:
        for item in changes:
            target = home / item['path']
            saved = backup / 'home' / item['path']
            if exists(target):
                saved.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(target), str(saved))
                if saved.is_symlink():
                    link = os.readlink(saved)
                    item['original_symlink'] = link
                    if not os.path.isabs(link):
                        saved.unlink()
                        saved.symlink_to(os.path.normpath(target.parent / link))
            metadata['changes'].append(item)
            journal.write_text(json.dumps(metadata, indent=2) + '\n')
            if item['source']:
                target.parent.mkdir(parents=True, exist_ok=True)
                target.symlink_to(item['source'], target_is_directory=Path(item['source']).is_dir())
        print('Backup:', backup)
        print('Rollback: python3', REPO / 'scripts/link.py', '--restore', backup)
    except BaseException:
        if journal.exists():
            restore(backup)
        raise


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
