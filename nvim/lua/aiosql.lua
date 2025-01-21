--
--
-- AIOSQL "go to definition":
local function find_sql_definition()
  -- Get the word under the cursor
  local word = vim.fn.expand("<cword>")

  -- Convert underscore to dash for SQL comment style
  local query_name = word:gsub("_", "-")

  -- More precise ripgrep search
  local cmd = string.format("rg -e '-- name: %s'", query_name)
  print(cmd)

  local results = vim.fn.systemlist(cmd)

  if #results > 0 then
    -- Parse the first result (file:line)
    local file, line = results[1]:match("(.+):(%d+):")
    print(file)
    print(line)
    if file then
      -- Open the file and go to the specific line
      vim.cmd("edit " .. file)
      vim.fn.cursor(tonumber(line), 1)
    end
  else
    vim.notify("SQL definition not found for: " .. word, vim.log.levels.WARN)
  end
end

-- Create a keybind (example in your init.lua)
-- do not use gds as conflicts with gd lsp
-- vim.keymap.set("n", "gds", find_sql_definition, { noremap = true, silent = true })

-- local fd = vim.fn.systemlist("rg -e '-- name: get-favourite-count'")
-- for file, line in ipairs(fd) do
-- 	print(file)
-- 	print(line)
-- end
