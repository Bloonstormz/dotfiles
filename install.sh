#!/bin/bash

set -euo pipefail

function link() {
    local src="$(realpath "$1")"
    local dest_dir="$(realpath "$2")"
    local dest_name
    if [[ $# -ge 3 ]]; then
        dest_name="$3"
    else
        dest_name="$(basename "$1")"
    fi

    local dest_path="$dest_dir/$dest_name"
    if [[ -e "$dest_path" ]]; then
        printf "$dest_path already exists. Override [y/n]?: "
        read -r -n 1 confirm
        printf "\n"
        if [[ $confirm == "y" ]]; then
            ln -sfT "$src" "$dest_path"
        fi
    else
        ln -sT "$src" "$dest_path"
    fi
}

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

pushd $SCRIPT_DIR 1>/dev/null

# Get all directories that aren't hidden
mapfile -t DIRS < <(find -maxdepth 1 -type d -not -name '.*')

for dir in "${DIRS[@]}"; do
    if ! [[ -e "$HOME/.config/$dir" ]]; then
        ln -sn "$(realpath "$dir")" "$HOME/.config/"
    fi
done

link "$SCRIPT_DIR/bashrc" "$HOME" ".bashrc"
link "$SCRIPT_DIR/bash_aliases" "$HOME" ".bash_aliases"

popd 1>/dev/null
