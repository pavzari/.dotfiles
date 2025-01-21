-- select all.
vim.keymap.set("n", "<leader>sa", "ggVG")

-- unhighlight search results.
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- replace %s all instances of highlighted word.
vim.keymap.set("v", "<leader>r", '"hy:%s/<c-r>h//g<left><left>')

-- move selected lines in visual mode up or down.
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")

-- move between splits.
vim.keymap.set("n", "<c-j>", "<c-w>j")
vim.keymap.set("n", "<c-k>", "<c-w>k")
vim.keymap.set("n", "<c-h>", "<c-w>h")
vim.keymap.set("n", "<c-l>", "<c-w>l")

-- resize splits with arrow keys.
vim.keymap.set("n", "<c-up>", ":resize -2<cr>")
vim.keymap.set("n", "<c-down>", ":resize +2<cr>")
vim.keymap.set("n", "<c-left>", ":vertical resize -2<cr>")
vim.keymap.set("n", "<c-right>", ":vertical resize +2<cr>")

-- execute lua in v selection or current line in n.
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- automatically close brackets, parenthesis, and quotes.
-- vim.keymap.set("i", "'", "''<left>")
-- vim.keymap.set("i", '"', '""<left>')
-- vim.keymap.set("i", "(", "()<left>")
-- vim.keymap.set("i", "[", "[]<left>")
-- vim.keymap.set("i", "{", "{}<left>")
