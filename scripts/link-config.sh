#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
source "$SCRIPT_DIR/lib/paths.sh"

mapfile -t packages < <(
	find "$DOTFILES_ROOT" -mindepth 1 -maxdepth 1 -type d | sort
)

backup_conflict() {
	local destination="$1"
	local relative_destination="${destination#"$TARGET_HOME"/}"
	local backup="$BACKUP_RUN/$relative_destination"

	if [[ -e "$backup" || -L "$backup" ]]; then
		printf 'Backup target already exists: %s\n' "$backup" >&2
		return 1
	fi

	mkdir -p -- "$(dirname -- "$backup")"
	mv -- "$destination" "$backup"
	printf 'Backed up %s -> %s\n' "$destination" "$backup"
}

confirm_conflict() {
	local destination="$1"
	local reply=""

	while true; do
		printf '%s already exists. (S)kip, (b)ackup or (r)eplace it? ' "$destination" >&2
		read -r reply || true
		case "${reply,,}" in
		b | backup)
			echo "backup"
			;;
		r | replace)
			echo "replace"
			return
			;;
		"" | s | skip)
			echo "skip"
			return
			;;
		*)
			echo "Unrecognized Option: '${reply}'" >&2
			;;
		esac
	done
}

link() {
	local source="$1"
	local destination="$2"
	local relative_source

	if ! [[ -e "$source" ]]; then
		return 0
	fi

	if [[ -L "$destination" ]] &&
		[[ "$(realpath -- "$destination")" == "$(realpath -- "$source")" ]]; then
		return 0
	fi

	if [[ -e "$destination" || -L "$destination" ]]; then
		case "$(confirm_conflict "$destination")" in
		"backup")
			backup_conflict "$destination"
			;;
		"replace")
			rm -f "$destination"
			;;
		"skip")
			printf 'Skipped %s\n' "$destination"
			return 0
			;;
		esac
	fi

	mkdir -p -- "$(dirname -- "$destination")"
	relative_source="$(realpath --relative-to="$(dirname -- "$destination")" "$source")"
	relative_wd="$(realpath --relative-to="$REPO_ROOT" "$source")"
	ln -s -- "$relative_source" "$destination"
	printf 'Linked %s -> ./%s\n' "$destination" "$relative_wd"
}

link_files() {
	local source_dir="$1"
	local destination_dir="$2"

	mapfile -t files < <(
		find "$source_dir" -maxdepth 1 -mindepth 1 -type f -not -name link.sh
	)
	for file in "${files[@]}"; do
		link "$file" "${destination_dir}/$(basename "$file")"
	done
}

command_exists() {
	command -v "$1" &>/dev/null
}

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
[[ -e "$REPO_ROOT/.config" ]] && source "$REPO_ROOT/.config"
for package in "${packages[@]}"; do
	if [[ -f "${package}/link.sh" ]]; then
		# shellcheck disable=SC1091
		source "${package}/link.sh"
	fi

	shall_run=false
	if [[ -v condition ]]; then
		if { $condition; } &>/dev/null; then
			shall_run=true
		fi
	else
		if command -v "$(basename "$package")" &>/dev/null; then
			shall_run=true
		fi
	fi

	if [[ "$shall_run" == true ]]; then
		if declare -F run_link >/dev/null; then
			run_link "$package"
		else
			link "$package" "${CONFIG}/$(basename "$package")"
		fi
	else
		echo "Skipping $(basename "$package")"
	fi

	unset -v condition
	unset -f run_link
done

link "$DOTFILES_ROOT/defaults" "$CONFIG/defaults"
