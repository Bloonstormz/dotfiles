run_link() {
	local dot_dir="$1"
	link_optional() {
		link "$dot_dir/optional/$1" "$CONFIG/niri/optional/$1"
	}

	link "$1/config.kdl" "$CONFIG/niri/config.kdl"
	link "$1/binds.kdl" "$CONFIG/niri/binds.kdl"
	link "$1/floating.kdl" "$CONFIG/niri/floating.kdl"
	link "$1/config.kdl.local" "$CONFIG/niri/config.kdl.local"

	{
		# Save some lines by not needing a bunch of if statements. We can chain && instead if errexit is not set
		set +x
		command_exists "hypridle" && link_optional "hypridle.kdl"
		command_exists "awww" && link_optional "awww.kdl"
		command_exists "waybar" && link_optional "waybar.kdl"
		command_exists "swaync" && link_optional "sway-nc.kdl"
		command_exists "gammastep" && link_optional "gammastep.kdl"
	}
}
