hl.config({
	input = {
		kb_layout = "gb",
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------

-- TODO: Convert to vim-like keybinds.
-- See https://wiki.hypr.land/configuring/code-snippets/#vim-like-keymaps

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(Options.modKey .. " + Q", hl.dsp.exec_cmd(Options.terminal))
hl.bind(Options.modKey .. " + C", hl.dsp.window.close())
hl.bind(
	Options.modKey .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(Options.modKey .. " + E", hl.dsp.exec_cmd(Options.fileManager))
hl.bind(Options.modKey .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(Options.modKey .. " + R", hl.dsp.exec_cmd(Options.menu))
hl.bind(Options.modKey .. " + P", hl.dsp.window.pseudo())
hl.bind(Options.modKey .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with Options.modKey + arrow keys
hl.bind(Options.modKey .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(Options.modKey .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(Options.modKey .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(Options.modKey .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with Options.modKey + [0-9]
-- Move active window to a workspace with Options.modKey + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(Options.modKey .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(Options.modKey .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(Options.modKey .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(Options.modKey .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with Options.modKey + scroll
hl.bind(Options.modKey .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(Options.modKey .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(Options.modKey .. " + SHIFT + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(Options.modKey .. " + SHIFT + left", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with Options.modKey + LMB/RMB and dragging
hl.bind(Options.modKey .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(Options.modKey .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(Options.volumeUp), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(Options.volumeDown), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(Options.volumeMute), { locked = true, repeating = true })
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(Options.brightnessUp), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(Options.brightnessDown), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
