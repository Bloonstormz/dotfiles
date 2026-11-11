#!/usr/bin/env bash
# shellcheck disable=SC2059

set -euo pipefail

SCRIPT_DIR="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
source "$SCRIPT_DIR/lib/colours.sh"
source "$SCRIPT_DIR/lib/paths.sh"

if command -v fd &>/dev/null; then
	mapfile -t symlinks < <(
		fd . "$HOME/.config" -t symlink -u
		fd . "$HOME" -t symlink -u -d 1
	)
else
	mapfile -t symlinks < <(
		find "$HOME/.config" -type l
		find "$HOME" -maxdepth 1 -type l
	)
fi

if [[ "${#symlinks[@]}" -eq 0 ]] || [[ "${#symlinks[@]}" -eq 1 && -z "${symlinks[0]}" ]]; then
	printf "${RED}Error${NORMAL}: No links to delete!\n"
	exit 1
fi

echo "$REPO_ROOT"
for file in "${symlinks[@]}"; do
	source_file="$(realpath -m "${file}")"
	if [[ "$source_file" =~ ^"$REPO_ROOT"/(.*) ]]; then
		printf "Deleting ${BLUE}%s${NORMAL}. (Linked to ${BLUE}%s${NORMAL})\n" "$file" "./${BASH_REMATCH[1]}"
		rm "$file"
	fi
done

find "$HOME/.config" -depth -type d -empty -delete
