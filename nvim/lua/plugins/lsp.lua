return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			require("mason").setup()

			require("mason-tool-installer").setup({
				ensure_installed = {
					"prettier",
					"stylua",
					"black",
					"shfmt",
					"ruff",
					-- "eslint_d",
				},
			})

			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)

			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"tsserver",
					"pyright",
					"html",
					"gopls",
				},

				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
						})
					end,

					-- Ruff installed via Mason produces identical diagnostics as a language server and a linter.
					-- Both have been merged into ruff proper.
					-- Disabling ruff linting via nvim-lint removes the duplicates.
					--
					-- https://docs.astral.sh/ruff/editors/settings/#lint_enable
					-- https://github.com/astral-sh/ruff-lsp/issues/384
					-- Disable ls linting for now and keep the nvim-lint config.
					["ruff"] = function()
						require("lspconfig").ruff.setup({
							init_options = {
								settings = {
									lint = {
										enable = false,
									},
								},
							},
						})
					end,

					["pyright"] = function()
						require("lspconfig").pyright.setup({
							capabilities = capabilities,
							filetypes = { "python" },
							settings = {
								python = {
									analysis = {
										typeCheckingMode = "basic", -- disable strict type checking.
									},
								},
							},
						})
					end,
				},
			})
		end,
	},
}
