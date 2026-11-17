run_link() {
	local dot_dir="$1"
	link_optional() {
		link "$dot_dir/optional/$1" "$CONFIG/niri/optional/$1"
	}

	link_files "$1" "$CONFIG/niri"

	{
		# Save some lines by not needing a bunch of if statements. We can chain && instead if errexit is not set
		set +x
		command_exists "hypridle" && link_optional "hypridle.kdl"
		command_exists "awww" && link_optional "awww.kdl"
		command_exists "waybar_auto_hide" && [[ "$CFG_WAYBAR_AUTO_HIDE" == Enabled ]] && link_optional "waybar-auto-hide.kdl"
		command_exists "waybar" && link_optional "waybar.kdl"
		command_exists "swaync" && link_optional "sway-nc.kdl"
		command_exists "gammastep" && link_optional "gammastep.kdl"
	}
}
