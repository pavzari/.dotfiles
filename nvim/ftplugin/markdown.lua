-- vim.opt.textwidth = 85
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.colorcolumn = "85"
vim.opt_local.breakindent = true
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = "yes"

-- For easier navigation in wrapped lines
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Navigate markdown links
vim.keymap.set(
  "n",
  "<Tab>",
  "<Cmd>call search('\\[[^]]*\\]([^)]\\+)')<CR>",
  { noremap = true, silent = true, buffer = 0 }
)
vim.keymap.set(
  "n",
  "<S-Tab>",
  "<Cmd>call search('\\[[^]]*\\]([^)]\\+)', 'b')<CR>",
  { noremap = true, silent = true, buffer = 0 }
)
