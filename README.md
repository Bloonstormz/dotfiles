# Dotfiles and Nix configuration

This repository keeps package installation separate from configuration files:

- `nix/packages/common.nix` is the portable CLI package set.
- `nix/packages/desktop.nix` contains NixOS desktop additions.
- `nix/nixos/` contains the shared NixOS module and host definitions.
- `dotfiles/` contains home-directory overlays using the GNU Stow layout.
- `scripts/` links and unlinks those overlays without requiring GNU Stow.

## Install packages with Nix

On a non-NixOS Linux machine with flakes enabled, install the common profile:

```sh
nix profile install .
```

After updating `flake.lock` or the package list, update the installed profile:

```sh
nix flake update
nix profile upgrade dotfiles-common
```

Profile generations can be inspected and rolled back with `nix profile history`
and `nix profile rollback`.

## Link configuration files

Link every package into the current `$HOME`:

```sh
./scripts/link.sh
```

Pass package names to link only part of the configuration:

```sh
./scripts/link.sh bash git nvim
```

Existing destinations are left alone unless replacement is confirmed. Replaced
files are moved into a timestamped directory under `.backups/`, preserving their
path relative to `$HOME`.

Remove links created for all or selected packages with:

```sh
./scripts/unlink.sh
./scripts/unlink.sh bash git
```

Unlinking only removes symlinks that still point into this repository. It does
not restore backups automatically.

Machine-specific, untracked files may be placed under `dotfiles/local/` using
the same home-directory layout. If present, `local` is linked by the default
command.

## NixOS desktop scaffold

`nixosConfigurations.desktop` composes the common packages with Ghostty and
creates the `minng01` user. Before deploying it, add the generated hardware
configuration plus the machine's boot loader, filesystems, authentication,
networking, and graphical environment to `nix/nixos/hosts/desktop.nix`.

The checked-in root filesystem value is an evaluation-only `REPLACE_ME`
placeholder and no bootloader is enabled. Once those host-specific settings
exist, build or switch with:

```sh
sudo nixos-rebuild build --flake .#desktop
sudo nixos-rebuild switch --flake .#desktop
```
