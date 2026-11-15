# Dotfiles

My dotfiles/nix OS configurations with a customizable install script to *roughly* set up a system.

# Requirements

- Linux

## Configuring/Installation

Allows choosing which programs to install (and then installs them)

- Bash
- Nix
- Python3
- One of the following distros:
  - Void Linux
  - NixOS (Support is a WIP. Requires some manual edits of `flake.nix` and `nix/nixos/hosts/`)

## Config Files Only

If you don't want this repo to install anything for you and just want my dotfiles

- Bash

# Usage

Run `./scripts/install.sh` to choose (and later install) the tools/programs you want.

If you want to just see what options there are, you can just run `./scripts/configure.py` instead.

If you only want my dotfiles, run `./scripts/link-config.sh`  
If you don't want to use my dotfiles anymore run `./scripts/unlink-config.sh`

# Credits

Waybar theme and associated scripts in `dotfiles/bin` are taken from https://github.com/cebem1nt/dotfiles/tree/c0c1ae5
