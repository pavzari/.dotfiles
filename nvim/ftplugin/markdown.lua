vim.opt.wrap = true
vim.opt.textwidth = 85
vim.opt.linebreak = true
vim.opt.colorcolumn = "85"

-- If you want soft wrapping without actual line breaks:
vim.opt.formatoptions:remove("t")
vim.opt.formatoptions:append("l")

-- For easier navigation in wrapped lines
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- If you want to hide markdown syntax
-- vim.opt.conceallevel = 2
