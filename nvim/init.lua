-- Set the Python provider path directly to speed things up on startup.
vim.g.python3_host_prog = "/home/pav/.pyenv/shims/python"

-- local function get_python_path()
-- 	local handle = io.popen("which python")
-- 	local result = handle:read("*a")
-- 	handle:close()
-- 	return result:gsub("%s+", "")
-- end
-- vim.g.python3_host_prog = get_python_path()

require("options")
require("keymaps")
require("autocmds")
require("statusline")
require("terminal")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
