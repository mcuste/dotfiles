-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove LazyVim's Lazy/LazyVim bindings (use :Lazy and :LazyVim directly)
vim.keymap.del("n", "<leader>l") -- Lazy
vim.keymap.del("n", "<leader>L") -- LazyVim Changelog

-- Remap new file from <leader>fn to <leader>bn
vim.keymap.del("n", "<leader>fn")
vim.keymap.set("n", "<leader>bn", "<cmd>enew<cr>", { desc = "New Buffer" })

-- Remove buffer picker keymaps
vim.keymap.del("n", "<leader>,") -- Buffer picker
vim.keymap.del("n", "<leader>fB") -- Buffers (cwd)
vim.keymap.del("n", "<leader>fT") -- Terminal (cwd)
vim.keymap.del("n", "<leader>st") -- Todo
vim.keymap.del("n", "<leader>sT") -- Todo/Fix/Fixme
vim.keymap.del("n", "<leader>sl") -- Location list
vim.keymap.del("n", "<leader>sq") -- Quickfix list
vim.keymap.del("n", '<leader>s"') -- Registers

-- Override LazyVim's default <C-h/j/k/l> window navigation with smart-splits
-- (LazyVim maps these to <C-w>h/j/k/l which doesn't cross tmux pane boundaries)
vim.keymap.set("n", "<C-h>", "<cmd>SmartCursorMoveLeft<cr>", { desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<cmd>SmartCursorMoveDown<cr>", { desc = "Move to split below" })
vim.keymap.set("n", "<C-k>", "<cmd>SmartCursorMoveUp<cr>", { desc = "Move to split above" })
vim.keymap.set("n", "<C-l>", "<cmd>SmartCursorMoveRight<cr>", { desc = "Move to right split" })
