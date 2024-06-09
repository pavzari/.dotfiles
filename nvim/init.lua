vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.opt.mouse = ""
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 10
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.splitbelow = true
vim.opt.wrap = false
vim.opt.virtualedit = "block"
vim.opt.termguicolors = true
vim.g.have_nerd_font = true
vim.opt.swapfile = false

-- Open error message in a floating window.
vim.keymap.set("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>")

-- %s substitution changes are previewed in a new split.
vim.opt.inccommand = "split"

-- Ignore case when invoking commands/and tabbing through them.
vim.opt.ignorecase = true

-- Set highlight on search, but clear on pressing <Esc> in normal mode.
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Highlight when yanking text.
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

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
