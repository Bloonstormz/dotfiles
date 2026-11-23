#!/usr/bin/env bash

UNITS_DIR="$(basename "$(realpath "$0")")"
DOTFILES_ROOT="$UNITS_DIR/../../.."

CFG_DISPLAY_THEME="${1^}" "$DOTFILES_ROOT/scripts/link-config.sh"
