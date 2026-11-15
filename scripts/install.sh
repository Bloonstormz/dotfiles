#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
source "$SCRIPT_DIR/lib/colours.sh"
source "$SCRIPT_DIR/lib/paths.sh"

CONFIGURE=false
while [[ "$#" -gt 0 ]]; do
	flag="$1"
	shift

	case "$flag" in
	-c | --config)
		CONFIGURE=true
		;;
	esac
done

if ! command -v nix >/dev/null 2>&1; then
	# shellcheck disable=SC2059
	printf "${RED}ERROR${NORMAL}: nix is required to install these dotfiles\n"
	exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
	# shellcheck disable=SC2059
	printf "${RED}ERROR${NORMAL}: python3 is required to install these dotfiles\n"
	exit 1
fi

REPO_ROOT="$(dirname -- "$SCRIPT_DIR")"

cd "$REPO_ROOT"

if uname -a | grep -iq nixos; then
	sudo nixos-rebuild switch --flake .
	printf "Linking configs\n"
	"$PWD/scripts/link-config.sh"
	exit 0
fi

# Non nix-os based distros.
# Prompt for certain settings and form a nix profile install <...> command accordingly

SKIP_NIX=false
if [[ -e "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/profile" ]] && ! [[ -z "$(nix profile list)" ]]; then
	while true; do
		printf "Nix profile already found! (d)elete, (A)dd onto it or (s)kip nix installs? "
		read -r reply || true
		case "${reply,,}" in
		d | delete)
			nix profile remove --all
			break
			;;
		"" | a | add)
			break
			;;
		s | skip)
			SKIP_NIX=true
			break
			;;
		*)
			echo "Unrecognized Option: '${reply}'" >&2
			;;
		esac
	done
fi

CONFIG_FILE="$REPO_ROOT/.config"
if [[ ! -e "$CONFIG_FILE" ]] || [[ "$CONFIGURE" == true ]]; then
	"$SCRIPT_DIR/configure.py"
fi

will_install() {
	for bin in "$@"; do
		local -n config="BIN_$bin"
		if [[ "${config}" == "host" || "${config}" == "nix" ]]; then
			return 0
		fi
	done
	return 1
}

source "$CONFIG_FILE"

if [[ "${#HOST_INSTALL[@]}" -gt 0 ]]; then
	if command -v xbps-install &>/dev/null; then
		if will_install "hypridle" "hyprlock"; then
			if ! grep -q "repository=https://mirror.black-hole.dev/$(xbps-uhelper arch)" /etc/xbps.d/00-repository-main.conf &>/dev/null; then
				printf "${YELLOW}WARNING: Hypridle/Hyprlock requires a third-part repository:${NORMAL} ${BLUE}https://github.com/Event-Horizon-VL/blackhole-vl${NORMAL}\n"
				printf "Proceed (y/N)? "
				read -r confirm
				if ! [[ "${confirm,,}" == "y" ]]; then
					exit 1
				fi
				[[ -e /etc/xbps.d/00-repository-main.conf ]] || sudo cp /usr/share/xbps.d/00-repository-main.conf /etc/xbps.d/
				echo "repository=https://mirror.black-hole.dev/$(xbps-uhelper arch)" | sudo tee -a /etc/xbps.d/00-repository-main.conf >/dev/null
			fi
		fi

		printf "sudo xbps-install -S "
		printf "%s " "${HOST_INSTALL[@]}"
		printf "\n"
		sudo xbps-install -S "${HOST_INSTALL[@]}"
	fi
fi

if [[ "${#NIX_INSTALL[@]}" -gt 0 && "$SKIP_NIX" == false ]]; then
	if command -v jq &>/dev/null; then
		nixrev="$(jq -r .nodes.nixpkgs.locked.rev "$REPO_ROOT/flake.lock")"
	else
		nixrev="$(nix-shell -p jq --run "jq -r .nodes.nixpkgs.locked.rev '$REPO_ROOT/flake.lock'")"
	fi
	FORMATTED_NIX_INSTALL=("github:nix-community/nixGL")
	for pkg in "${NIX_INSTALL[@]}"; do
		FORMATTED_NIX_INSTALL+=(
			"nixpkgs/$nixrev#$pkg"
		)
	done
	printf "nix profile add "
	printf "nixpkgs#%s " "${NIX_INSTALL[@]}"
	printf "\n"
	nix profile add --impure "${FORMATTED_NIX_INSTALL[@]}"
fi
