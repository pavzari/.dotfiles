local function setup_custom_highlight(diagnostic_name, default_background)
  -- Get the foreground colour of the diagnostic group.
  local diagnostic_fg = vim.api.nvim_get_hl_by_name(diagnostic_name, true).foreground
  -- Set up a custom highlight group with the same foreground and StatusLine background.
  vim.cmd(string.format("highlight! Status%s guifg=#%06x guibg=%s", diagnostic_name, diagnostic_fg, default_background))
end

local function lsp_diagnostics()
  local diagnostics = {
    { name = "Error", highlight = "DiagnosticError" },
    { name = "Warn", highlight = "DiagnosticWarn" },
    { name = "Hint", highlight = "DiagnosticHint" },
    { name = "Info", highlight = "DiagnosticInfo" },
  }
  local result = {}

  for _, diagnostic in ipairs(diagnostics) do
    local count = vim.tbl_count(vim.diagnostic.get(0, { severity = diagnostic.name }))
    if count ~= 0 then
      -- Get the background colour of the StatusLine.
      local statusline_bg = vim.api.nvim_get_hl_by_name("StatusLine", true).background
      -- local diag_letter = string.lower(diagnostic.name:sub(1, 1))
      setup_custom_highlight(diagnostic.highlight, string.format("#%06x", statusline_bg))
      table.insert(result, string.format("%%#Status%s# %d", diagnostic.highlight, count))
    end
  end
  return table.concat(result)
end

local git_status = function()
  local git_info = vim.b.gitsigns_status_dict
  if not git_info or git_info.head == "" then
    return ""
  end

  local statusline_bg = vim.api.nvim_get_hl_by_name("StatusLine", true).background
  local bg_hex = string.format("#%06x", statusline_bg)

  setup_custom_highlight("GitSignsAdd", bg_hex)
  setup_custom_highlight("GitSignsChange", bg_hex)
  setup_custom_highlight("GitSignsDelete", bg_hex)

  local function format_change(count, symbol, highlight)
    if count and count > 0 then
      return string.format("%%#Status%s#%s%%#StatusLine#%d", highlight, symbol, count)
    end
    return ""
  end

  local added = format_change(git_info.added, "+", "GitSignsAdd")
  local changed = format_change(git_info.changed, "~", "GitSignsChange")
  local removed = format_change(git_info.removed, "-", "GitSignsDelete")

  local changes = table.concat({ added, changed, removed })
  local space = changes ~= "" and " " or ""

  return table.concat({
    "(",
    "*",
    git_info.head,
    space,
    changes,
    ")",
  })
end

Statusline = {}

Statusline.active = function()
  return table.concat({
    "%F", -- Full file path
    " %m", -- Modified flag
    "%r", -- Readonly flag
    "%h", -- Help buffer flag
    "%w", -- Preview window flag
    git_status(),
    "%#StatusLine#",
    "%=", -- Switch to right side
    lsp_diagnostics(),
    " ",
    "%#StatusLine#",
    -- "%l:%c (%P)",
  })
end

function Statusline.inactive()
  return " %F"
end

local statusline_group = vim.api.nvim_create_augroup("Statusline", { clear = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = statusline_group,
  callback = function()
    vim.wo.statusline = "%!v:lua.Statusline.active()"
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = statusline_group,
  callback = function()
    vim.wo.statusline = "%!v:lua.Statusline.inactive()"
  end,
})
