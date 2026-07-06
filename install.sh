#!/bin/bash

set -euo pipefail

ALLOW_SUDO=false

while [[ $# -gt 0 ]]; do
    flag="$1"
    shift

    case "$flag" in
    -s | --sudo)
        ALLOW_SUDO=true
        ;;
    esac
done

SCRIPT_DIR="$(dirname "$(realpath "$0")")"

source "$SCRIPT_DIR/bashrc" || true

BASH_COMP="$HOME/.config/bash_comp"
ZSH_COMP="$HOME/.config/zsh_comp"

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

mkdir -p "$HOME/bin"

function check() {
    for package in "$@"; do
        command -v "$package" &>/dev/null || return 1
    done
    return 0
}
function prompt() {
    printf "%s [y/n]?: " "$1"
    read -r -n 1 confirm

    [[ $confirm == "\n" ]] || printf "\n"

    [[ $confirm == "y" ]] && return 0
    return 1
}
function prompt_install() {
    local package="$1"
    local name="${2:-"${package}"}"
    local confirm

    if check "$package"; then
        # Already installed
        return 1
    fi

    prompt "$name not installed. Install"
}

function sudo_access() {
    if [[ "$ALLOW_SUDO" == true ]]; then
        command -v sudo >/dev/null && return 0

        if {
            LANG='' sudo -n -v 2>&1 || true
        } | grep -q "may not run sudo"; then
            return 0
        fi
        ALLOW_SUDO=false # No need to check for sudo access anymore
    fi

    echo "Sudo access required. Aborting..." >&2
    return 1
}

function extract_tar() {
    local tarball="$1"
    local out_dir="./tmp.out"
    local strip=0
    shift
    while [[ $# -gt 0 ]]; do
        local flag="$1"
        shift
        case "$flag" in
        -o | --output)
            out_dir="$1"
            shift
            ;;
        -s | --strip)
            if [[ $# -gt 0 ]] && ! [[ "$1" =~ ^- ]]; then
                strip="$1"
                shift
            else
                strip=1
            fi
            ;;
        esac
    done

    if [[ $strip -gt 0 ]]; then
        ADDITIONAL_ARGS="--strip-components=$strip"
    else
        ADDITIONAL_ARGS=""
    fi

    mkdir -p "$out_dir"
    tar -xf "$tarball" -C "$out_dir" "$ADDITIONAL_ARGS"
}

function mason_install() {
    if ! check "nvim"; then
        echo "Neovim is required to install $1" >&2
        return 1
    fi
    nvim --headless -c "lua require('mason')" -c "MasonInstall $1" -c "qall"
    echo
}
ALLOW_PYTHON_VENV=true
function python_venv() {
    if [[ -d "${SCRIPT_DIR}/.venv" ]]; then
        return 0
    fi
    if [[ "$ALLOW_PYTHON_VENV" == false ]]; then
        return 1
    fi

    if ! pip3 show virtualenv &>/dev/null; then
        if prompt_install "non existant" "python module: virtualenv"; then
            if ! output="$(pip3 install virtualenv 2>&1)"; then
                if sudo_access; then
                    sudo apt install python3-virtualenv
                else
                    ALLOW_PYTHON_VENV=false
                    return 1
                fi
            else
                printf "%s\n" "$output" >&2
            fi
        else
            ALLOW_PYTHON_VENV=false
            return 1
        fi
    fi

    python3 -m virtualenv .venv
    source "${SCRIPT_DIR}/.venv/bin/activate"
}

# For python packages, if there already exists a virtualenv, then source it so that prompt_install can discover packages
if [[ -d "${SCRIPT_DIR}/.venv" ]]; then
    source "${SCRIPT_DIR}/.venv/bin/activate"
fi

DOWNLOAD_DIR="$SCRIPT_DIR/downloads"
mkdir -p "$DOWNLOAD_DIR"

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

if prompt_install "cargo" "Rust"; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
fi

if prompt_install "nvim" "Neovim"; then
    pushd "$DOWNLOAD_DIR" >/dev/null
    (
        set -e
        wget -O nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.12.3/nvim-linux-x86_64.tar.gz
        trap "rm nvim.tar.gz" EXIT

        extract_tar nvim.tar.gz -o ./nvim -s
        ln -sf "$(realpath ./nvim/bin/nvim)" "$HOME/bin/nvim"
    )
    popd >/dev/null
fi

if check nvim cargo; then
    if prompt_install "tree-sitter"; then
        cargo install --locked tree-sitter-cli
    fi
fi

if prompt_install "zsh"; then
    pushd "$DOWNLOAD_DIR" >/dev/null
    (
        set -e
        wget -O zsh.tar.xz https://www.zsh.org/pub/zsh-5.9.1.tar.xz
        trap "rm zsh.tar.xz" EXIT

        mkdir -p ./zsh
        tar -xf zsh.tar.xz -C ./zsh --strip-components=1
        pushd "./zsh" >/dev/null

        ./configure --prefix="$HOME"
        make
        make install

        popd >/dev/null

        # Install oh-my-zsh
        curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --keep-zshrc --unattended
        # Install powerlevel10k
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

        if prompt "Make zsh the default shell"; then
            ZSH="$(command -v zsh)"
            if ! [[ -e /etc/shells ]]; then
                echo "/etc/shells does not exit. Aborting.."
                exit 1
            fi
            if ! grep -q "$ZSH" /etc/shells; then
                echo "zsh not in /etc/shells. Updating"
                if ! sudo_access; then
                    echo "Sudo Access required. Aborting..."
                    exit 1
                fi
                echo "$ZSH" | sudo tee -a /etc/shells
            fi
            chsh -s "$ZSH"
        fi
    )
    popd >/dev/null
fi

if prompt_install "lazygit"; then
    pushd "$DOWNLOAD_DIR" >/dev/null
    (
        set -e
        wget -O lazygit.tar.gz https://github.com/jesseduffield/lazygit/releases/download/v0.62.2/lazygit_0.62.2_linux_x86_64.tar.gz
        trap "rm lazygit.tar.gz" EXIT

        extract_tar lazygit.tar.gz -o ./lazygit
        ln -sf "$(realpath ./lazygit/lazygit)" "$HOME/bin/lazygit"
    )

    popd >/dev/null
fi

if check "cargo" && prompt_install "rg" "ripgrep"; then
    # Build ripgrep manually as PCRE2 support is not included in prebuilt binaries
    pushd "$DOWNLOAD_DIR" >/dev/null
    (
        set -e
        git clone --branch 15.1.0 -- https://github.com/BurntSushi/ripgrep ripgrep_source
        trap "rm -rf ripgrep_source" EXIT
        cd ripgrep_source
        cargo build --release --features 'pcre2'
        cd ..

        mv ./ripgrep_source/target/release/rg .
        ln -sf "$(realpath ./rg)" "$HOME/bin/rg"
        ./rg --generate complete-bash >"$BASH_COMP/_rg"
        ./rg --generate complete-zsh >"$ZSH_COMP/_rg"
    )
    popd >/dev/null
fi

if check "cargo" && prompt_install "pay-respects"; then
    pushd "$DOWNLOAD_DIR" >/dev/null
    cargo install pay-respects
    popd >/dev/null
fi

if prompt_install "fd"; then
    pushd "$DOWNLOAD_DIR" >/dev/null
    (
        set -e
        wget -O fd.tar.gz https://github.com/sharkdp/fd/releases/download/v10.4.2/fd-v10.4.2-x86_64-unknown-linux-gnu.tar.gz
        trap "rm fd.tar.gz" EXIT

        extract_tar ./fd.tar.gz -o ./fd_out -s
        mv ./fd_out/fd .
        mv ./fd_out/autocomplete/fd.bash "$BASH_COMP"
        mv ./fd_out/autocomplete/_fd "$ZSH_COMP"
        ln -sf "$(realpath ./fd)" "$HOME/bin/fd"
        rm -rf ./fd_out
    )
    popd >/dev/null
fi

if prompt_install "bat"; then
    pushd "$DOWNLOAD_DIR" >/dev/null
    (
        set -e
        wget -O bat.tar.gz https://github.com/sharkdp/bat/releases/download/v0.26.1/bat-v0.26.1-x86_64-unknown-linux-gnu.tar.gz
        trap "rm bat.tar.gz" EXIT

        extract_tar "bat.tar.gz" -s -o bat
        ln -sf "$(realpath ./bat/bat)" "$HOME/bin/bat"

        ./bat/bat --config-file
        ./bat/bat --completion bash >"$ZSH_COMP/_bat"
        ./bat/bat --completion zsh >"$ZSH_COMP/_bat"

        link "$SCRIPT_DIR/configs/bat.config" "$(bat --config-file)"
    )
    popd >/dev/null
fi

if check "cargo" && prompt_install "delta"; then
    pushd "$DOWNLOAD_DIR" >/dev/null
    (
        set -e
        cargo install git-delta
        delta --generate-completion bash >"$BASH_COMP/_delta"
        delta --generate-completion zsh >"$ZSH_COMP/_delta"

        link "$SCRIPT_DIR/configs/delta.config" "$HOME/.config/git"

        echo "Downloading Catppuccin Themes for Delta"
        wget -O "$SCRIPT_DIR/configs/catppuccin.gitconfig" https://raw.githubusercontent.com/catppuccin/delta/refs/heads/main/catppuccin.gitconfig

        link "$SCRIPT_DIR/configs/catppuccin.gitconfig" "$HOME/.config/git"
    )
    popd >/dev/null
fi

# LSPs

if python_venv && prompt_install "ruff" "Ruff LSP"; then
    pip3 install ruff==0.15.13
fi

if prompt_install "pyright" "Pyright LSP"; then
    mason_install "pyright"
fi

if prompt_install "clangd" "Clangd"; then
    mason_install "clangd"
fi

if check npm; then
    if prompt_install "bash-language-server" "Bash Language Server"; then
        npm install -g bash-language-server@5.6.0
    fi
fi
