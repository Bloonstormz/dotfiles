run_link() {
	link "$1/colours" "$CONFIG/swaync/colours"
	link "$1/config.json" "$CONFIG/swaync/config.json"
	link "$1/style.css" "$CONFIG/swaync/style.css"

	case "${CFG_DISPLAY_THEME:-"Dark"}" in
	Light)
		soft_link -f "./light.css" "$CONFIG/swaync/colours/colours.css"
		;;
	*)
		# Use catch-all so that if display theme is valid, it falls back to light
		soft_link -f "./dark.css" "$CONFIG/swaync/colours/colours.css"
		;;
	esac
}
