if io.popen("command -v waybar"):read() ~= nil then
	hl.on("hyprland.start", function()
		hl.exec_cmd("waybar")
		hl.exec_cmd("sleep 1 && waybar_auto_hide &")
	end)
end
