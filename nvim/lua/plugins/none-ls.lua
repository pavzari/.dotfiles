return {
    "nvimtools/none-ls.nvim",

    dependencies = {
        "nvimtools/none-ls-extras.nvim",
    },
    config = function()
        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        local null_ls = require("null-ls")
        null_ls.setup({
            sources = {
                -- stylua, prettier, black, shfmt are installed via :Mason.
                null_ls.builtins.formatting.black,
                null_ls.builtins.formatting.stylua,
                null_ls.builtins.formatting.prettier,
                null_ls.builtins.formatting.shfmt,
                require("none-ls.diagnostics.eslint_d"),
            },
            -- auto-formatting on save: (taken from "Dreams of Code" video on Python + Nvim)
            on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_clear_autocmds({
                        group = augroup,
                        buffer = bufnr,
                    })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = bufnr })
                        end,
                    })
                end
            end,
        })
        vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
    end,
}
