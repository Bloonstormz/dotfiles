-- Only run if noctalia is installed
-- Updates associated defaults

if io.popen("command -v noctalia"):read() ~= nil then
	Options.menu = "noctalia msg panel-toggle launcher"

	Options.volumeDown = "noctalia msg volume-down 5"
	Options.volumeUp = "noctalia msg volume-up 5"
	Options.volumeMute = "noctalia msg volume-mute"
	Options.brightnessDown = "noctalia msg brightness-down 5"
	Options.brightnessUp = "noctalia msg brightness-up 5"

	hl.on("hyprland.start", function()
		hl.exec_cmd("noctalia")
	end)
end
