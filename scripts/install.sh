#!/usr/bin/env bash

set -euo pipefail

if [[ -t 1 && -t 2 ]]; then
	RED="\033[31m"
	NORMAL="\033[0m"
else
	RED=""
	NORMAL=""
fi

if ! command -v nix >/dev/null 2>&1; then
	# shellcheck disable=SC2059
	printf "${RED}ERROR${NORMAL}: nix is required to install these dotfiles\n"
fi

cd "$(dirname "$0")/.."

if uname -a | grep -iq nixos; then
	sudo nixos-rebuild switch --flake .
else
	nix profile install
fi
