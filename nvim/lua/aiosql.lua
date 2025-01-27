-- project root ?

local function add_to_tagstack(bufnr, pos, name)
  local item = { ["bufnr"] = bufnr, ["from"] = pos, ["tagname"] = name }
  local winid = vim.fn.win_getid()
  local tagstack = vim.fn.gettagstack(winid)
  table.insert(tagstack["items"], item)
  vim.fn.settagstack(winid, tagstack, "t")
end

local function find_sql_definition()
  local word = vim.fn.expand("<cword>")

  if not word or word == "" then
    vim.notify("No selection under cursor")
    return
  end

  local func_name = word:gsub("_cursor", "")
  local query_name = func_name:gsub("_", "-")
  local search_cmd = string.format("rg -e 'name: %s' --vimgrep --glob '*.sql'", query_name)
  local results = vim.fn.systemlist(search_cmd)

  if vim.v.shell_error ~= 0 then
    -- try search without _/- sub
    search_cmd = string.format("rg -e 'name: %s' --vimgrep --glob '*.sql'", func_name)
    results = vim.fn.systemlist(search_cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify("No matches found for: -- name: " .. query_name)
      return
    end
  end

  for _, line in ipairs(results) do
    local file, line_num, col_num = line:match("([^:]+):(%d+):(%d+):")
    if file and line_num and col_num then
      return { file = file, line_num = line_num, col_num = col_num, func_name = func_name }
    end
  end
end

local function goto_sql_definition()
  local query = find_sql_definition()
  if query == nil then
    return
  end
  local current_bufnr = vim.fn.bufnr()
  local current_pos = vim.fn.getcurpos()
  add_to_tagstack(current_bufnr, current_pos, query.func_name)
  vim.cmd("e " .. query.file)
  vim.api.nvim_win_set_cursor(0, { tonumber(query.line_num), tonumber(query.col_num) - 1 })
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
    col = 0,
    row = 0,
    style = "minimal",
    border = "rounded",
  })

  vim.api.nvim_set_option_value("filetype", "sql", { buf = buf })

  local current_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = current_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
end

local function hover_sql_definition()
  local query = find_sql_definition()
  if query == nil then
    return
  end
  local file = vim.fn.readfile(query.file)
  local starts = tonumber(query.line_num)
  local ends = 0

  for i = starts + 1, #file do
    if file[i]:match("^%s*-- name:") then
      ends = i - 1
      break
    end
  end

  local content = {}
  for i = starts, ends do
    table.insert(content, file[i])
  end

  show_float(content)
  return
end

vim.keymap.set("n", "<leader>sq", goto_sql_definition, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>sh", hover_sql_definition, { noremap = true, silent = true })
