# Dotfiles

The files in this repository are the real configuration files. `install.sh`
links them into the home directory, while Nix and Home Manager install the
programs they configure.

## Install

Install [Nix](https://nixos.org/download/) with flakes enabled, then run:

```sh
./install.sh
```

The first run creates `flake.lock` and downloads the pinned packages. Later
runs reuse the lock file and only apply changes.

To update packages:

```sh
nix flake update
./install.sh
```

The username and home directory are read from `USER` and `HOME` when the
installer runs. The target architecture is declared near the top of
`flake.nix`; change it there when installing on a different platform.
