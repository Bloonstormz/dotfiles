#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")"
source "$SCRIPT_DIR/lib/colours.sh"
source "$SCRIPT_DIR/lib/paths.sh"

function print_help() {
	echo "Flags:"
	echo "    -c|--configure                         Always run configure.py before installing"
	echo "    -n|--nix [(d)elete, (A)dd, (s)kip]     How to handle existing nix profiles"
	echo "    -d|--dry-run                           Dry Run"
	echo "    -u|--update-host                       Update host package database"
	echo "    -H|--no-host                           Skip host package installations"
	echo "    -N|--no-nix                            Skip nix profile installations"
	echo "    -h|--help                              Print this help text"
}

CONFIGURE=false
DRY_RUN=false
UPDATE_HOST=false
SKIP_HOST=false
SKIP_NIX=false
while [[ "$#" -gt 0 ]]; do
	flag="$1"
	shift

	case "$flag" in
	-c | --config)
		CONFIGURE=true
		;;
	-n | --nix)
		reply="$1"
		shift
		;;
	-d | --dry-run)
		DRY_RUN=true
		;;
	-u | --update-host)
		UPDATE_HOST=true
		;;
	-H | --no-host)
		SKIP_HOST=true
		;;
	-N | --no-nix)
		SKIP_NIX=true
		;;
	-h | --help)
		print_help
		exit 0
		;;
	*)
		echo "Unrecognized option: $flag" >&2
		print_help
		exit 1
		;;
	esac
done

if [[ "$SKIP_NIX" == false ]] && ! command -v nix >/dev/null 2>&1; then
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

if [[ "$SKIP_NIX" == false ]] && [[ -e "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/profile" ]] && ! [[ -z "$(nix profile list)" ]]; then
	while true; do
		if ! [[ -v reply ]]; then
			printf "Nix profile already found! (d)elete, (A)dd onto it or (s)kip nix installs? "
			read -r reply || true
		fi
		case "${reply,,}" in
		d | delete)
			if [[ "$DRY_RUN" == true ]]; then
				printf "nix profile remove --all\n"
			else
				nix profile remove --all
			fi
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
		unset reply
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

if [[ "${#HOST_INSTALL[@]}" -gt 0 && "$SKIP_HOST" == false ]]; then
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

		if [[ "$UPDATE_HOST" == true ]]; then
			UPDATE_ARG="-S "
		else
			UPDATE_ARG=""
		fi
		printf "sudo xbps-install %s\\ \n" "$UPDATE_ARG"
		printf "    %s \\ \n" "${HOST_INSTALL[@]}"
		if [[ "$DRY_RUN" == false ]]; then
			sudo xbps-install ${UPDATE_ARG}"${HOST_INSTALL[@]}"
		fi
	elif command -v pacman &>/dev/null; then
		if [[ "$UPDATE_HOST" == true ]]; then
			UPDATE_ARG="-yu "
		else
			UPDATE_ARG=""
		fi
		printf "sudo pacman -S%s \\ \n" "$UPDATE_ARG"
		printf "    %s \\ \n" "${HOST_INSTALL[@]}"
		if [[ "$DRY_RUN" == false ]]; then
			sudo pacman -S${UPDATE_ARG} "${HOST_INSTALL[@]}"
		fi
	fi
fi

if [[ "${#NIX_INSTALL[@]}" -gt 0 && "$SKIP_NIX" == false ]]; then
	printf "nix profile add --impure \\ \n"
	printf "    %s \\ \n" "${NIX_INSTALL[@]}"
	if [[ "$DRY_RUN" == false ]]; then
		nix profile add --impure "${NIX_INSTALL[@]}"
	fi
fi
