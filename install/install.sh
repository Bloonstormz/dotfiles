#!/bin/bash

set -euo pipefail

ALLOW_SUDO=false
CLEAN=false

while [[ $# -gt 0 ]]; do
	flag="$1"
	shift

	case "$flag" in
	-s | --sudo)
		ALLOW_SUDO=true
		;;
	-c | --clean-install)
		CLEAN=true
		;;
	esac
done

mkdir -p "$HOME/bin"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
DOTFILE_DIR="$(realpath "$SCRIPT_DIR/..")"

source "$SCRIPT_DIR/lib/link.sh"

function maybe_rm() {
	local item="$1"
	shift
	if [[ -e "$item" ]]; then
		rm "$@" "$item"
	fi
}

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

function add_unique() {
	local -n arr_ref="$1"
	local candidate="$2"

	for existing in "${arr_ref[@]}"; do
		if [[ "$existing" == "$candidate" ]]; then
			return 0
		fi
	done

	arr_ref+=("$candidate")
}

function update_ready_list() {
	local completed="$1"
	local status="${2:-success}"
	local -a new_ready=()
	local -a still_pending=()
	local file

	for file in "${READY[@]}"; do
		if [[ "$file" != "$completed" ]]; then
			add_unique new_ready "$file"
		fi
	done

	if [[ "$status" == "success" ]]; then
		for file in "${PENDING[@]}"; do
			if [[ "$file" == "$completed" ]]; then
				continue
			fi

			if (
				source "$file"
				if [[ -v DEPS ]]; then
					check "${DEPS[@]}"
				else
					true
				fi
			); then
				add_unique new_ready "$file"
			else
				still_pending+=("$file")
			fi
		done
	else
		still_pending=("${PENDING[@]}")
	fi

	READY=("${new_ready[@]}")
	PENDING=("${still_pending[@]}")
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
	if [[ -d "${DOTFILE_DIR}/.venv" ]]; then
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
	source "${DOTFILE_DIR}/.venv/bin/activate"
}

# For python packages, if there already exists a virtualenv, then source it so that prompt_install can discover packages
if [[ -d "${DOTFILE_DIR}/.venv" ]]; then
	source "${DOTFILE_DIR}/.venv/bin/activate"
fi

BASH_COMP="$HOME/.config/bash_comp"
ZSH_COMP="$HOME/.config/zsh_comp"
DOWNLOAD_DIR="$DOTFILE_DIR/downloads"
mkdir -p "$DOWNLOAD_DIR/lsp" "$BASH_COMP" "$ZSH_COMP"

export PATH="$PATH:${XDG_DATA_HOME:-"$HOME/.local/share/nvim/mason/bin/"}"

# Discover binaries to install
READY=()
PENDING=()
for file in "$SCRIPT_DIR"/binaries/*.sh; do
	source "$file"

	if [[ ! -v DEPS ]]; then
		add_unique READY "$file"
	else
		add_unique PENDING "$file"
	fi

	unset -v BIN NAME DEPS
	unset -f do_install do_complete
done

function clean() {
	(
		set -e
		pushd "$DOWNLOAD_DIR" >/dev/null
		do_clean
	) && {
		# This is allowed to fail as failing to clean completions
		# does not affect whether the binary failed to be clean
		if command -v do_complete &>/dev/null; then
			do_complete | while IFS= read -r cmd_format; do
				: "$cmd_format"
				if IFS= read -r bin_name; then
					comp_bin="${bin_name,,}"
				else
					comp_bin="${BIN,,}"
				fi
				maybe_rm "$BASH_COMP/_$comp_bin" "$ZSH_COMP/_$comp_bin"
			done
			unset -v comp_bin cmd_format bin_name
		fi
		true
	}
}

while :; do
	if [[ "${#READY[@]}" -eq 0 ]]; then
		break
	fi

	for file in "${READY[@]}"; do
		unset -v BIN NAME DEPS
		unset -f do_install do_complete do_clean
		source "$file"

		NAME="${NAME:-"${BIN}"}"
		if check "$BIN"; then
			if [[ "$CLEAN" == true ]] &&
				prompt "$NAME already installed. Clean"; then
				clean || {
					echo "Failed to clean (exit $?)"
					update_ready_list "$file" "failure"
					continue
				}
			else
				update_ready_list "$file" "success"
				continue
			fi
		fi

		if ! prompt_install "$BIN" "$NAME"; then
			update_ready_list "$file" "failure"
			continue
		fi

		(
			pushd "$DOWNLOAD_DIR" >/dev/null
			set -e
			do_install
		) || {
			echo "Failed to install $NAME (exit $?)"
			update_ready_list "$file" "failure"
			continue
		}

		update_ready_list "$file" "success"

		command -v do_complete &>/dev/null && {
			do_complete | while IFS= read -r cmd_format; do
				if IFS= read -r bin_name; then
					comp_bin="${bin_name,,}"
				else
					comp_bin="${BIN,,}"
				fi
				{ printf "$cmd_format >%s/_%s\n" "bash" "$BASH_COMP" "$comp_bin" | bash; } || echo "Failed to generate completion for bash"
				{ printf "$cmd_format >%s/_%s\n" "zsh" "$ZSH_COMP" "$comp_bin" | bash; } || echo "Failed to generate completion for zsh"
				unset -v comp_bin cmd_format bin_name
			done
		}
	done
	unset -v BIN NAME DEPS
	unset -f do_install do_complete do_clean
done

# LSPs

# Python based LSPs are installed manually as Mason only supports python -m venv
# which is not always available.
# See:
#  - https://github.com/mason-org/mason.nvim/issues/1841
#  - https://github.com/mason-org/mason.nvim/pull/1640
#  - Potential Solution to this would be:
#     https://github.com/mason-org/mason.nvim/pull/1640#issuecomment-4295111276
#     but this is not a public API and could(?) break. Also requires some knowledge of Mason code
if python_venv && prompt_install "ruff" "Ruff LSP"; then
	pip3 install ruff==0.15.13
	ln -sf "$(which ruff)" "$DOWNLOAD_DIR/lsp/"
fi
