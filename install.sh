#!/bin/bash

set -euo pipefail

function link() {
    local src="$(realpath "$1")"
    local dest_dir="$(realpath "$2")"
    local dest_name="$(basename "$1")"

    if [[ -e "$dest_dir/$dest_name" ]]; then
        printf "$dest_dir/$dest_name already exists. Override [y/n]?: "
        read -r -n 1 confirm
        printf "\n"
        if [[ $confirm == "y" ]]; then
            ln -sf "$src" "$dest_dir"
        fi
    else
        ln -s "$src" "$dest_dir"
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

link "$SCRIPT_DIR/.bashrc" "$HOME"
link "$SCRIPT_DIR/.bash_aliases" "$HOME"

popd 1>/dev/null
