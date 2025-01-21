return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
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
          "shellcheck",
          "sql-formatter",
          -- "eslint_d",
        },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      ---@diagnostic disable-next-line: missing-fields
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "ts_ls",
          "basedpyright",
          "html",
          "gopls",
          "bashls", -- uses shellcheck by default for linting.
        },

        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
            })
          end,

          -- Use ruff bin for linting/diagnostics from ruff server via lspconfig (nvim-lint not needed)
          -- formatting and autofixing via conform. Pyright does the rest.
          ["ruff"] = function()
            require("lspconfig").ruff.setup({
              on_attach = function(client, bufnr)
                if client.name == "ruff" then
                  client.server_capabilities.hoverProvider = false
                end
              end,
              capabilities = capabilities,
              init_options = {
                settings = {
                  lint = {
                    -- remove duplicates with pyright.
                    ignore = { "F821" },
                    enable = true,
                  },
                },
              },
            })
          end,

          ["basedpyright"] = function()
            require("lspconfig").basedpyright.setup({
              capabilities = capabilities,
              settings = {
                basedpyright = {
                  disableOrganizeImports = true,
                  typeCheckingMode = "standard",
                },
              },
            })
          end,
        },
      })

      -- Lsp keymaps.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
        callback = function(event)
          local map = function(keys, func)
            vim.keymap.set("n", keys, func, { buffer = event.buf })
          end
          map("gd", vim.lsp.buf.definition) -- jump to the definition. Jump back: <c-t>.
          map("ds", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>") -- gd but opens in a new split.
          map("gr", "<cmd>lua require('fzf-lua').lsp_references()<cr>")
          map("<leader>rn", vim.lsp.buf.rename) -- rename the symbol under cursor.
          map("<leader>ca", vim.lsp.buf.code_action) -- code actions selection.
          map("<leader>e", vim.diagnostic.open_float) -- show diagnostics in a float.
          map("<leader>q", "<cmd>lua require('fzf-lua').diagnostics_document()<cr>")
          map("<leader>wss", vim.lsp.buf.workspace_symbol)
          map("<leader>i", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
          end)
        end,
      })

      -- Use numcol for diagnostics.
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticError",
            [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
          },
        },
        severity_sort = true,
        virtual_text = {
          severity = { min = vim.diagnostic.severity.ERROR },
        },
        float = {
          source = true,
          header = "",
        },
      })
    end,
  },
}
