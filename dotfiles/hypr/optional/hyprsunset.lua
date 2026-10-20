if CommandExists("hyprsunset") then
	table.insert(Options.autoStart, "hyprsunset")

	Options.brightnessDown = "hyprctl hyprsunset gamma -10"
	Options.brightnessDown = "hyprctl hyprsunset gamma +10"
end
