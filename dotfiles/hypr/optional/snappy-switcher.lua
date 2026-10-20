if CommandExists("snappy-switcher") then
	table.insert(Options.autoStart, "snappy-switcher --daemon")

	hl.bind(
		Options.modKey .. " + TAB",
		hl.dsp.exec_cmd("snappy-switcher next --workspace --mod " .. string.lower(Options.modKey))
	)
	hl.bind("ALT + TAB", hl.dsp.exec_cmd("snappy-switcher next --mod alt"))
end
