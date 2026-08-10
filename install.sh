#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

source "$SCRIPT_DIR/bashrc" || true

source "$SCRIPT_DIR/install/lib/link.sh"

set -euo pipefail

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/bash_comp"
mkdir -p "$HOME/.config/zsh_comp"
mkdir -p "$HOME/.config/git"

pushd "$SCRIPT_DIR" 1>/dev/null

# Get all directories that aren't gitignored, hidden, not install/ or configs/
mapfile -t to_ignore < <(awk '/[^^/]+$/ {print $0}' .gitignore)
to_ignore+=(".*" "install" "configs")
# Use %s instead of %q to allow globbing. Surround it with '' to avoid issues with spaces
mapfile -t DIRS < <(printf -- "-a -not -name '%s' " "${to_ignore[@]}" | xargs find . -maxdepth 1 -type d)

for dir in "${DIRS[@]}"; do
    confirm_link "$dir" "$HOME/.config/$dir"
done

link "$SCRIPT_DIR/bashrc" "$HOME" ".bashrc"
link "$SCRIPT_DIR/sh_aliases" "$HOME/.config" ".sh_aliases"

link "$SCRIPT_DIR/zshrc" "$HOME" ".zshrc"
link "$SCRIPT_DIR/p10k.zsh" "$HOME" ".p10k.zsh"

link "$SCRIPT_DIR/localrc" "$HOME/.config" ".localrc"
link "$SCRIPT_DIR/local_aliases" "$HOME/.config" ".local_aliases"

link "$SCRIPT_DIR/sh_profile" "$HOME/.config" ".profile"

link "$SCRIPT_DIR/gitconfig" "$HOME" ".gitconfig"
link "$SCRIPT_DIR/local.gitconfig" "$HOME/.config/git" "local.gitconfig"
link "$SCRIPT_DIR/configs/delta.config" "$HOME/.config/git" "delta.config"
link "$SCRIPT_DIR/configs/catppuccin.gitconfig" "$HOME/.config/git" "catppuccin.gitconfig"
link "$SCRIPT_DIR/configs/bat.config" "$HOME/.config/bat" "config"

popd 1>/dev/null

# Install packages without asking Home Manager to own any dotfiles.
if ! command -v nix >/dev/null 2>&1; then
    echo "Nix is required. Install it from https://nixos.org/download/ and rerun this script." >&2
    exit 1
fi

exec nix --extra-experimental-features "nix-command flakes" --impure \
    run "path:$SCRIPT_DIR#home-manager" -- \
    switch --impure --flake "path:$SCRIPT_DIR#default" "$@"
