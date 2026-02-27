#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

pushd $SCRIPT_DIR 1>/dev/null

# Get all directories that aren't hidden
mapfile -t DIRS < <(find -maxdepth 1 -type d -not -name .* -and -not -name .)

for dir in "${DIRS[@]}"; do
    if ! [[ -e "$HOME/.config/$dir" ]]; then
        ln -sn "$(realpath "$dir")" "$HOME/.config/"
    fi
done

popd 1>/dev/null
