condition=true

run_link() {
	local files
	mapfile -t files < <(
		find "$1" -maxdepth 1 -mindepth 1 -type f -not -name link.sh
	)
	for file in "${files[@]}"; do
		link "$file" "$CONFIG/Pictures/$(basename "$file")"
	done
}
