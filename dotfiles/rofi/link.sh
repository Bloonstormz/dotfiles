run_link() {
	link "$1/themes" "$CONFIG/rofi/themes"
	link "$1/config.rasi" "$CONFIG/rofi/config.rasi"

	case "${CFG_DISPLAY_THEME:-"Dark"}" in
	Light)
		soft_link -f "./light.rasi" "$CONFIG/rofi/themes/colours/colours.rasi"
		;;
	*)
		# Use catch-all so that if display theme is valid, it falls back to light
		soft_link -f "./dark.rasi" "$CONFIG/rofi/themes/colours/colours.rasi"
		;;
	esac
}
