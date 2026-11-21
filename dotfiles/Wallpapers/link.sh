condition=true

run_link() {
	link_files "$1" "$CONFIG/Wallpapers"
	link_files "$1/local" "$CONFIG/Wallpapers"
}
