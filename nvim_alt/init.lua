vim.opt.mouse = "a"
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.path:append("**")

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

vim.opt.scrolloff = 10
-- vim.opt.sidescrolloff = 10

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.smartcase = true

vim.opt.breakindent = true
vim.opt.wrap = false

-- vim.opt.spelllang = "en_gb"
-- vim.opt.spell = true

vim.opt.clipboard = "unnamedplus"
vim.opt.inccommand = "split"
vim.opt.virtualedit = "block"
vim.opt.termguicolors = true
vim.g.have_nerd_font = true
vim.opt.swapfile = false
vim.g.python3_host_prog = os.getenv("HOME") .. "/.pyenv/shims/python"

vim.cmd("colorscheme quiet")
vim.cmd([[
  highlight Normal guibg=#232136 guifg=#d4d4d4
  "highlight Keyword gui=bold
  highlight Comment gui=italic
  "highlight Constant guifg=#999999
  highlight Constant guifg=#A99C7D
  highlight Function guifg=#789978
  highlight Directory guifg=#789978
  highlight Visual guifg=#908caa
  highlight Pmenu guibg=#2a273f guifg=#d4d4d4
  highlight Statusline guibg=#2a273f guifg=#999999 gui=none
]])

-- select all.
vim.keymap.set("n", "<leader>sa", "ggVG")

-- unhighlight search results.
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- replace %s all instances of highlighted word.
vim.keymap.set("v", "<leader>r", '"hy:%s/<c-r>h//g<left><left>')

-- move selected lines in visual mode up or down.
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")

-- move between splits.
vim.keymap.set("n", "<c-j>", "<c-w>j")
vim.keymap.set("n", "<c-k>", "<c-w>k")
vim.keymap.set("n", "<c-h>", "<c-w>h")
vim.keymap.set("n", "<c-l>", "<c-w>l")

-- resize splits with arrow keys.
vim.keymap.set("n", "<c-up>", ":resize -2<cr>")
vim.keymap.set("n", "<c-down>", ":resize +2<cr>")
vim.keymap.set("n", "<c-left>", ":vertical resize -2<cr>")
vim.keymap.set("n", "<c-right>", ":vertical resize +2<cr>")

-- execute lua in v selection or current line in n.
vim.keymap.set("n", "<leader>x", ":.lua<CR>")
vim.keymap.set("v", "<leader>x", ":lua<CR>")

-- lsp/diagnostics
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
  callback = function(event)
    local map = function(keys, func)
      vim.keymap.set("n", keys, func, { buffer = event.buf })
    end
    map("gd", vim.lsp.buf.definition) -- jump to the definition. Jump back: <c-t>.
    map("ds", "<cmd>vsplit | lua vim.lsp.buf.definition()<CR>") -- gd but opens in a new split.
    map("gr", "<cmd>lua require('fzf-lua').lsp_references()<cr>")
    map("<leader>rn", vim.lsp.buf.rename) -- rename the symbol under cursor.
    map("<leader>ca", vim.lsp.buf.code_action) -- code actions selection.
    map("<leader>e", vim.diagnostic.open_float) -- show diagnostics in a float.
    map("<leader>q", "<cmd>lua require('fzf-lua').diagnostics_document()<cr>")
    map("<leader>wss", vim.lsp.buf.workspace_symbol)
    map("<leader>i", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown-filetype", { clear = true }),
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.colorcolumn = "85"
    vim.opt_local.breakindent = true
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "yes"

    -- For easier navigation in wrapped lines
    vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
    vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
  end,
})

-- highlight when yanking text.
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      "nvim-treesitter/nvim-treesitter",
      dependencies = {
        "nvim-treesitter/nvim-treesitter-textobjects",
      },
      build = ":TSUpdate",
      config = function()
        local config = require("nvim-treesitter.configs")
        ---@diagnostic disable-next-line: missing-fields
        config.setup({
          auto_install = true,
          highlight = { enable = true },
          indent = { enable = true },
          textobjects = {
            select = {
              enable = true,
              lookahead = true,
              keymaps = {
                ["ip"] = "@parameter.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["al"] = "@loop.outer",
                ["il"] = "@loop.inner",
                ["ap"] = "@scope.outer",
              },
              include_surrounding_whitespace = false,
            },
          },
        })
      end,
    },
    {
      "saghen/blink.cmp",
      version = "*",
      opts = {
        keymap = { preset = "default" },
        appearance = {
          use_nvim_cmp_as_default = false,
          nerd_font_variant = "mono",
        },
        signature = { enabled = true },
        completion = {
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
            window = {
              winhighlight = "Pmenu:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
            },
          },
          menu = {
            draw = {
              columns = {
                { "label", "label_description", gap = 1 },
                { "kind_icon", "kind", gap = 1 },
                { "source_name" },
              },
            },
          },
        },
      },
    },
    {
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
    },
    {
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
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "saghen/blink.cmp",
        {
          "folke/lazydev.nvim",
          ft = "lua",
          opts = {
            library = {
              { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
          },
        },
      },
      config = function()
        local capabilities = require("blink.cmp").get_lsp_capabilities()
        local lsp = require("lspconfig")

        lsp.lua_ls.setup({
          capabilities = capabilities,
        })

        lsp.ruff.setup({
          on_attach = function(client, bufnr)
            if client.name == "ruff" then
              client.server_capabilities.hoverProvider = false
            end
          end,
          capabilities = capabilities,
          init_options = {
            settings = {
              lint = {
                ignore = { "F821" },
                enable = true,
              },
            },
          },
        })

        lsp.basedpyright.setup({
          capabilities = capabilities,
          settings = {
            basedpyright = {
              disableOrganizeImports = true,
              typeCheckingMode = "standard",
            },
          },
        })
      end,
    },
    {
      "stevearc/oil.nvim",
      config = function()
        require("oil").setup({
          view_options = {
            show_hidden = true,
          },
        })
      end,
      vim.keymap.set("n", "-", "<CMD>Oil<CR>"),
    },
  },
  change_detection = {
    enabled = false,
    notify = false,
  },
})
