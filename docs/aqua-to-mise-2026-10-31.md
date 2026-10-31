# Aqua to mise migration

The dotfiles now use mise as the only CLI/version manager. The standalone Aqua
executable, proxy directory, global YAML configuration, and checksum file are no
longer required. Some mise tool identifiers use its built-in `aqua:` backend;
that registry backend does not invoke or depend on the Aqua executable.

## Version choices

GitHub CLI 2.83.0 and ecspresso 2.6.3 come from the previous global Aqua config.
The additional AWS, linting, security, policy, and Terraform tools use their
newest already-cached Aqua versions. terraform-config-inspect keeps its exact
cached source revision. The stale tfmigrate command had no installed binary;
it is now pinned to 0.4.6.

Trivy is the approved exception: the previous 0.61.1 release could not be
installed through mise, so the owner approved upgrading it to stable 0.76.1.

Existing Go 1.24.2 and Terraform 1.1.8 remain the defaults. The former global
Aqua versions, Go 1.27.1 and Terraform 1.13.5, are installed as alternatives.
All pins live in `home/.config/mise/config.toml`.

## Applying cleanup

The replacements are installed in the current WSL environment and the linked
zsh configuration removes inherited Aqua paths and environment variables.
To retire the old home-directory Aqua links, run outside the Codex sandbox:

```sh
bash ~/.local/share/dotfiles/install.sh --migrate
exec zsh -l
```

The obsolete global configs were copied before removal to
`~/.local/state/dotfiles/aqua-retirement/20261031-181011/` on this WSL machine.
The linker uses these local snapshots when backing up a legacy symlink whose
source was removed from the repository, so rollback restores file contents
instead of a broken link. The old Aqua cache is retained as inactive rollback
data; it is not placed on PATH or used by the replacements.

## Scope and verification

This migration covers the tools available in the old Aqua installation and the
dotfiles configuration. Other repositories' project-specific `aqua.yaml` files
and CI workflows are unchanged. Those projects must migrate their own version
selection and CI setup; mise does not interpret their Aqua YAML.

All former proxy command names, plus slsa-verifier, resolve inside mise's own
installation directory. Versions/help were exercised, terraform-config-inspect
parsed a Terraform fixture, and the new Trivy and tfmigrate binaries executed.
`mise doctor` reports no problems in zsh with no Aqua path or global variables.
Installer tests cover retirement of Aqua files and snapshot-backed rollback.
