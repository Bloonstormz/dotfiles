hl.on("workspace.created", function(ws)
	if ws.is_empty then
		hl.exec_cmd(Options.menu)
	end
end)
