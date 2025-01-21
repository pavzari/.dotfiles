return {
  "ibhagwan/fzf-lua",
  config = function()
    require("fzf-lua").setup({})
  end,
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>" },
    { "<leader>fg", "<cmd>FzfLua live_grep<cr>" },
    { "<leader>fh", "<cmd>FzfLua helptags<cr>" },
    { "<leader>fn", "<cmd>:lua require('fzf-lua').files({cwd=vim.fn.stdpath('config')})<cr>" },
    { "<leader>fw", "<cmd>lua require('fzf-lua').grep_cword()<cr>" },
  },
}
