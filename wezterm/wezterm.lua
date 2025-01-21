local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrains Mono", { weight = "Light", italic = false })
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
config.color_scheme = "rose-pine-moon"
config.font_size = 15
config.enable_tab_bar = false
-- NONE causes window sizing issues:
-- config.window_decorations = "NONE"
config.window_decorations = "RESIZE"
config.enable_scroll_bar = false
-- config.freetype_load_target = "Light"
config.freetype_load_flags = "NO_HINTING"
config.front_end = "WebGpu"

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

return config
