run_link() {
	link "$1/colours/light.css" "$CONFIG/waybar/colours/light.css"
	link "$1/colours/dark.css" "$CONFIG/waybar/colours/dark.css"
	link "$1/style.css" "$CONFIG/waybar/style.css"
	link "$1/config.jsonc" "$CONFIG/waybar/config.jsonc"

	case "${DISPLAY_THEME:-"Dark"}" in
	Light)
		ln -sf "./light.css" "$CONFIG/waybar/colours/colours.css"
		;;
	*)
		# Use catch-all so that if waybar theme is valid, it falls back to light
		ln -sf "./dark.css" "$CONFIG/waybar/colours/colours.css"
		;;
	esac
}
