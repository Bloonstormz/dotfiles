#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(dirname -- "$SCRIPT_DIR")"
DOTFILES_ROOT="$REPO_ROOT/dotfiles"
TARGET_HOME="${HOME:?HOME must be set}"
TARGET_HOME="${TARGET_HOME%/}"

if [[ -z "$TARGET_HOME" || "$TARGET_HOME" != /* || "$TARGET_HOME" == "/" ]]; then
  printf 'Refusing unsafe HOME: %s\n' "$TARGET_HOME" >&2
  exit 1
fi

prune_empty_parents() {
  local directory="$1"

  while [[ "$directory" != "$TARGET_HOME" ]]; do
    if ! rmdir -- "$directory" 2>/dev/null; then
      break
    fi
    directory="$(dirname -- "$directory")"
  done
}

unlink_tree() {
  local source_directory="$1"
  local destination_directory="$2"
  local source destination
  local -a entries

  shopt -s nullglob dotglob
  entries=("$source_directory"/*)
  shopt -u nullglob dotglob

  for source in "${entries[@]}"; do
    destination="$destination_directory/$(basename -- "$source")"
    if [[ -d "$source" && ! -L "$source" ]]; then
      unlink_tree "$source" "$destination"
    elif [[ -L "$destination" ]] &&
      [[ "$(realpath -- "$destination")" == "$(realpath -- "$source")" ]]; then
      rm -- "$destination"
      printf 'Unlinked %s\n' "$destination"
      prune_empty_parents "$(dirname -- "$destination")"
    fi
  done
}

if (( $# == 0 )); then
  mapfile -t packages < <(
    find "$DOTFILES_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
  )
else
  packages=("$@")
fi

for package in "${packages[@]}"; do
  if [[ "$package" == */* || "$package" == "." || "$package" == ".." || ! -d "$DOTFILES_ROOT/$package" ]]; then
    printf 'Unknown dotfile package: %s\n' "$package" >&2
    exit 1
  fi
  unlink_tree "$DOTFILES_ROOT/$package" "$TARGET_HOME"
done
