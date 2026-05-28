#!/bin/bash

set -euo pipefail

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
    local src="$(realpath "$1")"
    local dest_dir="$(realpath "$2")"
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
    local src_path="$(fake_realpath "$1")"
    local dest_path="$(fake_realpath "$2")"
    if [[ -e "$dest_path" || -L "$dest_path" ]]; then

        if [[ -L "$dest_path" ]] && [[ "$(realpath "$dest_path")" == "$(realpath "$src_path")" ]]; then
            return
        fi

        printf "$dest_path already exists. Override [y/n]?: "
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

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

pushd $SCRIPT_DIR 1>/dev/null

# Get all directories that aren't hidden
mapfile -t DIRS < <(find -maxdepth 1 -type d -not -name '.*')

for dir in "${DIRS[@]}"; do
    confirm_link "$dir" "$HOME/.config/$dir"
done

link "$SCRIPT_DIR/bashrc" "$HOME" ".bashrc"
link "$SCRIPT_DIR/sh_aliases" "$HOME/.config" ".sh_aliases"

link "$SCRIPT_DIR/zshrc" "$HOME" ".zshrc"

link "$SCRIPT_DIR/localrc" "$HOME/.config" ".localrc"
link "$SCRIPT_DIR/local_aliases" "$HOME/.config" ".local_aliases"

link "$SCRIPT_DIR/sh_profile" "$HOME/.config" ".profile"

link "$SCRIPT_DIR/gitconfig" "$HOME" ".gitconfig"

popd 1>/dev/null

# Install packages

function prompt_install() {
    local package="$1"
    local name="${2:-"${package}"}"
    local confirm

    if command -v "$package" &>/dev/null; then
        # Already installed
        return 1
    fi

    printf "%s not installed. Install [y/n]?: " "$name"
    read -r -n 1 confirm
    printf "\n"

    if [[ $confirm == "y" ]]; then
        return 0
    fi
    return 1
}
function mason_install() {
    nvim -c "MasonInstall $1" -c "qall"
}
function python_venv() {
    if [[ -d "${SCRIPT_DIR}/.venv" ]]; then
        return 0
    fi
    python3 -m virtualenv .venv
    source "${SCRIPT_DIR}/.venv/bin/activate"
}

# For python packages, if there already exists a virtualenv, then source it so that prompt_install can discover packages
if [[ -d "${SCRIPT_DIR}/.venv" ]]; then
    source "${SCRIPT_DIR}/.venv/bin/activate"
fi

export PATH="$PATH:${XDG_DATA_HOME:-"$HOME/.local/share/nvim/mason/bin/"}"

set +e # Allow installation failures

if prompt_install "node"; then
    # Taken from node.js.org/en/download

    # Download and install nvm:
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

    # Hide warnings about not being able to evaluate $HOME source
    # shellcheck disable=SC1091
    \. "$HOME/.nvm/nvm.sh" # in lieu of restarting the shell

    # Download and install Node.js:
    nvm install 24
fi

if prompt_install "ruff" "Ruff LSP"; then
    python_venv

    pip3 install ruff==0.15.13
fi

if prompt_install "pyright" "Pyright LSP"; then
    mason_install "pyright"
fi

if prompt_install "clangd" "Clangd"; then
    mason_install "clangd"
fi

if prompt_install "bash-language-server" "Bash Language Server"; then
    npm install -g bash-language-server@5.6.0
fi
