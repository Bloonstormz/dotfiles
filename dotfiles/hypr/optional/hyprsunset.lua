if CommandExists("hyprsunset") then
	Options.brightnessDown = "hyprctl hyprsunset gamma -10"
	Options.brightnessDown = "hyprctl hyprsunset gamma +10"
end
