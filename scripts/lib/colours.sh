# shellcheck disable=SC2034

if [[ -t 1 && -t 2 ]]; then
	RED="\033[31m"
	BLUE="\033[94m"
	NORMAL="\033[0m"
else
	RED=""
	BLUE=""
	NORMAL=""
fi
