run_link() {
	link "$1/themes" "$CONFIG/rofi/themes"
	link "$1/config.rasi" "$CONFIG/rofi/config.rasi"

	case "${DISPLAY_THEME:-"Dark"}" in
	Light)
		ln -sf "./light.rasi" "$CONFIG/rofi/themes/colours/colours.rasi"
		;;
	*)
		# Use catch-all so that if display theme is valid, it falls back to light
		ln -sf "./dark.rasi" "$CONFIG/rofi/themes/colours/colours.rasi"
		;;
	esac
}
