# shellcheck disable=SC2034
condition="command -v hyprland"

run_link() {
	link "$1" "$CONFIG/hypr"
}
