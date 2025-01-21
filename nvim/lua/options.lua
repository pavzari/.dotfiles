vim.opt.mouse = "a"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.path:append("**")

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.scrolloff = 10
-- vim.opt.sidescrolloff = 10

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes:1"
vim.opt.numberwidth = 3

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.smartcase = true

vim.opt.breakindent = true
vim.opt.wrap = false

vim.opt.spelllang = "en_gb"
vim.opt.spell = true

vim.opt.clipboard = "unnamedplus"
vim.opt.inccommand = "split"
vim.opt.virtualedit = "block"
vim.opt.termguicolors = true
vim.g.have_nerd_font = true
vim.opt.swapfile = false
vim.g.python3_host_prog = os.getenv("HOME") .. "/.pyenv/shims/python"
