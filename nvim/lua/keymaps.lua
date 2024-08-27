-- select all.
vim.keymap.set("n", "<leader>sa", "ggVG")

-- unhighlight search results.
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- replace %s all instances of highlighted word.
vim.keymap.set("v", "<leader>r", '"hy:%s/<c-r>h//g<left><left>')

-- exit terminal without closing it.
vim.keymap.set("t", "<esc>", [[<c-\><c-n>]])

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

-- automatically close brackets, parenthesis, and quotes.
vim.keymap.set("i", "'", "''<left>")
vim.keymap.set("i", '"', '""<left>')
vim.keymap.set("i", "(", "()<left>")
vim.keymap.set("i", "[", "[]<left>")
vim.keymap.set("i", "{", "{}<left>")

-- via telescope, show and select a register to paste from.
vim.keymap.set("i", "<c-p>", function()
	require("telescope.builtin").registers()
end, { remap = true, silent = false })

-- LSP and diagnostics.
vim.api.nvim_create_autocmd("lspattach", {
	group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
	callback = function(event)
		local map = function(keys, func)
			vim.keymap.set("n", keys, func, { buffer = event.buf })
		end
		map("K", vim.lsp.buf.hover) -- display info about symbol under cursor. [default]
		map("gd", vim.lsp.buf.definition) -- jump to the definition. Jump back: <c-t>.
		map("gr", require("telescope.builtin").lsp_references) -- find references for the symbol under cursor.
		map("<leader>rn", vim.lsp.buf.rename) -- rename the symbol under cursor.
		map("<leader>ca", vim.lsp.buf.code_action) -- code actions selection.
		map("<leader>e", vim.diagnostic.open_float) -- show diagnostics in a float.
		map("<leader>q", require("telescope.builtin").diagnostics) -- show diagnostics list.
		map("<leader>wss", vim.lsp.buf.workspace_symbol)
	end,
})
