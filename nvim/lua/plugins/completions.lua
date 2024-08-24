return {
	{
		-- Completion engine.
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip", -- Snippet engine and source.
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets", -- Snippets.
			"hrsh7th/cmp-nvim-lsp", -- Lsp auto-completion.
			"hrsh7th/cmp-cmdline", -- Cmdline auto-completion.
			"hrsh7th/cmp-buffer", -- Buffer auto-completion.
			"hrsh7th/cmp-path", -- Path auto-completion.
			"onsails/lspkind.nvim", -- Source type pictograms.
		},
		config = function()
			local cmp = require("cmp")
			local lspkind = require("lspkind")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				-- Specify the snippet engine.
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				formatting = {
					expandible_indicator = true,
					fields = {
						"abbr",
						"kind",
						"menu",
					},
					format = lspkind.cmp_format({
						mode = "symbol_text",
						maxwidth = 50,
						ellipsis_char = "...",
						menu = {
							path = "[Path]",
							buffer = "[Buffer]",
							luasnip = "[LuaSnip]",
							nvim_lsp = "[LSP]",
							nvim_lua = "[Lua]",
						},
					}),
				},
				-- Set completion source precedence.
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(), -- Trigger nvim-cmp manually.
					["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Accept completion.
					["<C-n>"] = cmp.mapping.select_next_item(), -- Select the next item.
					["<C-p>"] = cmp.mapping.select_prev_item(), -- Select the previous item.
					["<C-b>"] = cmp.mapping.scroll_docs(-4), -- Scroll docs.
					["<C-f>"] = cmp.mapping.scroll_docs(4), -- Scroll docs.
					["<C-e>"] = cmp.mapping.abort(), -- Close completion window.

					-- Move to the next/previous expansion location.
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
			})
			-- Buffer completions when searching "/".
			cmp.setup.cmdline("/", {
				sources = {
					{ name = "buffer" },
				},
			})
			-- Path and command completions for ":".
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
					{ name = "cmdline" },
				}),
			})
		end,
	},
}
