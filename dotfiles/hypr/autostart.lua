hl.on("hyprland.start", function()
	for _, value in ipairs(Options.autoStart) do
		hl.exec_cmd(value)
	end

	hl.exec_cmd(Options.terminal)
	hl.exec_cmd(Options.browser, {
		workspace = "2",
	})
end)
