#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

source "$SCRIPT_DIR/bashrc" || true

# If the path provided is a relative path, pre-pend PWD to it else, do nothing
# This is to gets an absolute path without resolving symlinks unlike `realpath`
function fake_realpath() {
    if [[ "$1" =~ ^(/|~) ]]; then
        echo "$1"
    else
        if [[ "$1" =~ ^\.[^.] ]]; then
            echo "$PWD/${1:2}"
        else
            echo "$PWD/$1"
        fi
    fi
}

function link() {
    local src dest_dir
    src="$(realpath "$1")"
    dest_dir="$(realpath "$2")"
    local dest_name

    if ! [[ -e "$src" ]]; then
        return 0
    fi

    if [[ $# -ge 3 ]]; then
        dest_name="$3"
        shift 3
    else
        dest_name="$(basename "$1")"
        shift 2
    fi

    confirm_link "$src" "$dest_dir/$dest_name"
}

# 1st argument: Path to source file/directory
# 2nd argument: Path of the destination link
#   Note: Name of the destination file/directory should be included in this argument
function confirm_link() {
    local src_path dest_path
    src_path="$(fake_realpath "$1")"
    dest_path="$(fake_realpath "$2")"
    if [[ -e "$dest_path" || -L "$dest_path" ]]; then

        if [[ -L "$dest_path" ]] && [[ "$(realpath "$dest_path")" == "$(realpath "$src_path")" ]]; then
            return
        fi

        printf "%s already exists. Override [y/n]?: " "$dest_path"
        read -r -n 1 confirm
        printf "\n"
        if [[ $confirm == "y" ]]; then
            rm -rf "$dest_path"
            ln -sfT "$src_path" "$dest_path"
        fi
    else
        ln -sT "$src_path" "$dest_path"
    fi
}

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
