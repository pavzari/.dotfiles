local function toggle_terminal()
  -- Find the first terminal buffer and its number.
  local term_bufnr = nil
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(bufnr):match("term://") then
      term_bufnr = bufnr
      break
    end
  end

  if not term_bufnr then
    -- If no terminal exists, create a new one.
    vim.cmd("botright split | terminal")
    vim.cmd("resize 10")
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.cursorline = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.spell = false
    vim.cmd("startinsert")
  else
    -- If terminal exists, toggle its visibility.
    local term_winnr = vim.fn.bufwinnr(term_bufnr)
    if term_winnr == -1 then
      -- Terminal exists but is not visible, show it.
      vim.cmd("botright split")
      vim.cmd("buffer " .. term_bufnr)
      vim.cmd("resize 10")
      vim.cmd("startinsert")
    else
      -- Terminal is visible, hide it
      vim.cmd(term_winnr .. "close")
    end
  end
end

local function move_terminal_to_right()
  vim.cmd("wincmd L")
  vim.cmd("vertical resize 60")
end

-- Always switch to insert mode when moving to terminal split.
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
  pattern = "term://*",
  command = "startinsert",
})

-- Remove terminal buffer status line.
vim.api.nvim_create_autocmd({ "TermEnter" }, {
  callback = function()
    vim.opt.laststatus = 0
  end,
})

vim.api.nvim_create_autocmd({ "TermLeave" }, {
  callback = function()
    vim.opt.laststatus = 3
  end,
})

vim.keymap.set("t", "<leader>r", move_terminal_to_right, { noremap = true, silent = true })
vim.keymap.set("t", "<esc>", [[<c-\><c-n>]]) -- exit terminal insert mode.
vim.keymap.set({ "n", "t" }, "<leader>`", toggle_terminal, { noremap = true, silent = true }) -- toggle_terminal.
vim.keymap.set("t", "<leader>q", [[<C-\><C-n>:bd!<CR>]], { noremap = true, silent = true }) -- delete terminal buffer.
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { noremap = true, silent = true }) -- move to above split without exiting insert mode.
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { noremap = true, silent = true }) -- move to left split without exiting insert mode.
