# shellcheck disable=SC2034
condition="command -v hyprland || command -v hypridle || command -v hyprlock || command -v hyprpaper || command -v hyprsunset"

run_link() {
	link "$1" "$CONFIG/hypr"
}
