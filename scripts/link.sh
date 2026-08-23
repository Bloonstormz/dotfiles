#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(dirname -- "$SCRIPT_DIR")"
DOTFILES_ROOT="$REPO_ROOT/dotfiles"
BACKUP_RUN="$REPO_ROOT/.backups/$(date -u +%Y%m%dT%H%M%SZ)-$$"
TARGET_HOME="${HOME:?HOME must be set}"
TARGET_HOME="${TARGET_HOME%/}"

if [[ -z "$TARGET_HOME" || "$TARGET_HOME" != /* || "$TARGET_HOME" == "/" ]]; then
  printf 'Refusing unsafe HOME: %s\n' "$TARGET_HOME" >&2
  exit 1
fi

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

link_leaf() {
  local source="$1"
  local destination="$2"
  local relative_source

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
  ln -s -- "$relative_source" "$destination"
  printf 'Linked %s -> %s\n' "$destination" "$relative_source"
}

link_tree() {
  local source_directory="$1"

  [[ -d "$source_directory" ]] || return 0

  local destination_directory="$2"
  local source destination
  local -a entries

  if [[ -e "$destination_directory" && ! -d "$destination_directory" ]] ||
    [[ -L "$destination_directory" ]]; then
    if ! confirm_conflict "$destination_directory"; then
      printf 'Skipped directory %s\n' "$destination_directory"
      return 0
    fi
    backup_conflict "$destination_directory"
  fi
  mkdir -p -- "$destination_directory"

  shopt -s nullglob dotglob
  entries=("$source_directory"/*)
  shopt -u nullglob dotglob

  for source in "${entries[@]}"; do
    destination="$destination_directory/$(basename -- "$source")"
    if [[ -d "$source" && ! -L "$source" ]]; then
      link_tree "$source" "$destination"
    else
      link_leaf "$source" "$destination"
    fi
  done
}

if (($# == 0)); then
  mapfile -t packages < <(
    find "$DOTFILES_ROOT" -mindepth 1 -maxdepth 1 -type d -not -name 'local' -printf '%f\n' | sort
  )
else
  packages=("$@")
fi

for package in "${packages[@]}"; do
  if [[ ! -d "$DOTFILES_ROOT/$package" && ! -d "$DOTFILES_ROOT/local/$package" ]]; then
    printf 'Unknown dotfile package: %s\n' "$package" >&2
    exit 1
  fi

  link_tree "$DOTFILES_ROOT/$package" "$TARGET_HOME"
  link_tree "$DOTFILES_ROOT/local/$package" "$TARGET_HOME"

done
