return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				markdown = { "prettier" },
				lua = { "stylua" },
				bash = { "shfmt" },
				html = { "prettier" },
				css = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				-- python = { "black" },
				python = {
					"ruff_fix",
					"ruff_format",
					"ruff_organize_imports",
				},
			},
			format_on_save = {
				lsp_format = "fallback",
			},
		})
		vim.keymap.set({ "n", "v" }, "<leader>gf", function()
			conform.format({
				lsp_format = "fallback",
			})
		end)
	end,
}
