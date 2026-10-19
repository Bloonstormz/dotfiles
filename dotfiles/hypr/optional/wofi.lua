if io.popen("command -v wofi"):read() ~= nil then
	Options.menu = "wofi --show drun"
end
