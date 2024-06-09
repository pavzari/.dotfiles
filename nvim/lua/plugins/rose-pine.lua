return {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
        local config = require("rose-pine")
        config.setup({
            variant = "moon",
        })
        vim.cmd.colorscheme("rose-pine")
    end,
}
