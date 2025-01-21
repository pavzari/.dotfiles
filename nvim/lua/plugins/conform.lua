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
        sh = { "shfmt" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        sql = { "sql_formatter" },
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

    conform.formatters.sql_formatter = {
      prepend_args = { "-l", "postgresql", "-c", '{"keywordCase":"upper"}' },
    }

    vim.keymap.set({ "n", "v" }, "<leader>gf", function()
      conform.format({
        lsp_format = "fallback",
      })
    end)
  end,
}
