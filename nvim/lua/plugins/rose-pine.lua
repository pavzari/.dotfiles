return {
  "rose-pine/neovim",
  name = "rose-pine",
  config = function()
    local config = require("rose-pine")
    config.setup({
      variant = "moon",
      disable_italics = true,
    })
    vim.cmd.colorscheme("rose-pine")

    -- vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
    -- vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
    -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    -- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
  end,
}
