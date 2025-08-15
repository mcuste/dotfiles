-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable nerd font support for better icons
vim.g.have_nerd_font = true

-- Disable Ruby provider (not needed)
vim.g.loaded_ruby_provider = 0
-- Disable Perl provider (not needed)
vim.g.loaded_perl_provider = 0

-- NOTE: Basic vim options are set by mini.basics plugin
-- This file contains additional customizations

local o = vim.o
local opt = vim.opt

-- ========== Additional Settings ==========

-- Sync with system clipboard
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

-- Faster update time for CursorHold events
o.updatetime = 250
-- Time to wait for mapped sequence
o.timeoutlen = 300
-- Show invisible characters (customized from mini.basics)
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.list = true
-- Live preview of substitutions
o.inccommand = 'split'
-- Keep 10 lines visible above/below cursor
o.scrolloff = 10
-- Ask for confirmation on unsaved changes
o.confirm = true

-- Auto-save when switching buffers/windows
o.autowrite = true
-- Disable swap files to avoid conflicts
o.swapfile = false

-- ========== Appearance ==========

-- Show relative line numbers for easier navigation
o.relativenumber = true
-- Enable 24-bit RGB colors in terminal
o.termguicolors = true
-- Single global statusline for all windows
o.laststatus = 3
-- Keep 8 columns visible when scrolling horizontally
o.sidescrolloff = 8
-- Hide markup for bold/italic in markdown
o.conceallevel = 2
-- Block cursor in all modes
o.guicursor = 'n-v-c-i:block'
-- Better window borders
opt.fillchars:append 'vert:┃,horiz:━,horizdown:┳,horizup:┻,verthoriz:╋,vertleft:┫,vertright:┣'

-- ========== Folding ==========

-- Use treesitter for code folding
o.foldmethod = 'expr'
o.foldexpr = 'nvim_treesitter#foldexpr()'
-- Start with all folds open
o.foldenable = false

-- ========== Editing ==========

-- Use spaces instead of tabs
o.expandtab = true
-- Display width of tab character
o.tabstop = 4
-- Spaces to use for indentation
o.shiftwidth = 2
-- Round indent to multiple of shiftwidth
o.shiftround = true
-- Text formatting options
o.formatoptions = 'jcroqlnt'
-- Disable spell check by default
o.spell = false
-- Spell check language
opt.spelllang = { 'en' }
