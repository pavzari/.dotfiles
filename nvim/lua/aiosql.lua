-- TODO: project root for rg search
local M = {}

local function add_to_tagstack(bufnr, pos, name)
  local winid = vim.fn.win_getid()
  local tagstack = vim.fn.gettagstack(winid)
  table.insert(tagstack.items, { bufnr = bufnr, from = pos, tagname = name })
  vim.fn.settagstack(winid, tagstack, "t")
end

local function search_ripgrep(query)
  -- TODO: avoid matching single/ partial word...?
  local search_cmd = string.format("rg -e 'name: %s' --vimgrep --glob '*.sql'", query)
  local results = vim.fn.systemlist(search_cmd)
  if vim.v.shell_error == 0 then
    return results
  end
  return nil
end

local function find_sql_definition()
  local word = vim.fn.expand("<cword>"):gsub("_cursor", "")
  if not word or word == "" then
    vim.notify("No selection under cursor")
    return
  end

  -- try search without _/- sub
  -- TODO: mixed - and _
  local results = search_ripgrep(word:gsub("_", "-")) or search_ripgrep(word)
  if not results then
    vim.notify("No matches found for: -- name: " .. word:gsub("_", "-"))
    return
  end

  for _, line in ipairs(results) do
    local file, line_num, col_num = line:match("([^:]+):(%d+):(%d+):")
    if file and line_num and col_num then
      return { file = file, line_num = line_num, col_num = col_num, func_name = word }
    end
  end
end

local function show_float(content, opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.3)
  local height = opts.height or math.floor(vim.o.lines * 0.3)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "cursor",
    width = width,
    height = height,
    col = 2,
    row = 0,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_set_option_value("filetype", "sql", { buf = buf })

  vim.api.nvim_create_autocmd({ "CursorMoved", "BufLeave" }, {
    buffer = vim.api.nvim_get_current_buf(),
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end

function M.goto_sql_definition()
  local query = find_sql_definition()
  if query == nil then
    return
  end

  add_to_tagstack(vim.fn.bufnr(), vim.fn.getcurpos(), query.func_name)

  vim.cmd("edit " .. query.file)
  vim.api.nvim_win_set_cursor(0, { tonumber(query.line_num), tonumber(query.col_num) - 1 })
end

function M.hover_sql_definition()
  local query = find_sql_definition()
  if query == nil then
    return
  end

  local file = vim.fn.readfile(query.file)
  local starts = tonumber(query.line_num)
  local float_width = 0
  local content = {}

  for i = starts, #file do
    if string.len(file[i]) > float_width then
      float_width = string.len(file[i])
    end
    if #file[i] > 0 then
      table.insert(content, file[i])
    end
    if i == #file or file[i + 1]:match("^%s*-- name:") then
      break
    end
  end

  show_float(content, { height = #content, width = float_width })
end

vim.keymap.set("n", "<leader>Q", M.goto_sql_definition, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>F", M.hover_sql_definition, { noremap = true, silent = true })

return M
