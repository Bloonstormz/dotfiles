#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

source "$SCRIPT_DIR/bashrc" || true

source "$SCRIPT_DIR/install/lib/link.sh"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/bash_comp"
mkdir -p "$HOME/.config/zsh_comp"
mkdir -p "$HOME/.config/git"

pushd "$SCRIPT_DIR" 1>/dev/null

# Get all directories that aren't hidden
mapfile -t DIRS < <(find . -maxdepth 1 -type d -not -name '.*')

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

popd 1>/dev/null

# Install packages
"$SCRIPT_DIR/install/install.sh" "$@"
