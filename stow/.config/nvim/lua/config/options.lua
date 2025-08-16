-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- This file contains only custom options that differ from or extend LazyVim defaults

-- General (custom settings)
vim.o.swapfile = false -- Disable swapfiles
vim.o.backup = false -- Don't store backup while overwriting the file
vim.o.writebackup = false -- Don't store backup while overwriting the file

vim.cmd("filetype plugin indent on") -- Enable all filetype plugins

-- Appearance (custom settings)
vim.o.breakindent = true -- Indent wrapped lines to match line start
vim.o.laststatus = 3 -- Always show a single instance of status line for different panes
vim.o.guicursor = "n-v-c-i:block"
vim.o.ruler = false -- Don't show cursor position in command line
vim.o.fillchars = "eob: " -- Don't show `~` outside of buffer
vim.o.sidescrolloff = 8 -- Min num of screen columns to keep to the left and to the right of the cursor

vim.opt.shortmess:append("WcC") -- Reduce command line messages
vim.o.splitkeep = "screen" -- Reduce scroll during window split

vim.opt.fillchars:append("vert:┃,horiz:━,horizdown:┳,horizup:┻,verthoriz:╋,vertleft:┫,vertright:┣") -- Bold borders

vim.g.have_nerd_font = true -- Have a Nerd Font installed and selected in the terminal

vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false -- disable folds by default

-- Editing (custom settings)
vim.o.incsearch = true -- Show search results while typing
vim.o.inccommand = "split" -- Preview substitutions live, as you type! (LazyVim: "nosplit")
vim.o.infercase = true -- Infer letter cases for a richer built-in keyword completion
vim.o.formatoptions = "jcroqlnt" -- tcqj
vim.o.spell = false -- Disable spelling by default (can toggle on during edit)

-- LazyVim Options
vim.g.lazyvim_picker = "snacks"
vim.g.lazyvim_blink_main = true
vim.g.ai_cmp = false
vim.g.lazyvim_mini_snippets_in_completion = false
vim.g.lazyvim_eslint_auto_format = true
vim.g.lazyvim_rust_diagnostics = "bacon-ls"
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"

-- Enable the option to require a Prettier config file
-- If no prettier config file is found, the formatter will not be used
vim.g.lazyvim_prettier_needs_config = false
