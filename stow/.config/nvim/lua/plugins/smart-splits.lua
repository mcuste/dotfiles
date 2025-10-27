-- Smart Window Management
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- resizing splits
    vim.keymap.set("n", "<A-S-h>", require("smart-splits").resize_left, { desc = "Resize split left" })
    vim.keymap.set("n", "<A-S-j>", require("smart-splits").resize_down, { desc = "Resize split down" })
    vim.keymap.set("n", "<A-S-k>", require("smart-splits").resize_up, { desc = "Resize split up" })
    vim.keymap.set("n", "<A-S-l>", require("smart-splits").resize_right, { desc = "Resize split right" })
    -- moving between splits
    vim.keymap.set("n", "<C-h>", "<cmd>SmartCursorMoveLeft<cr>", { desc = "Move to left split" })
    vim.keymap.set("n", "<C-j>", "<cmd>SmartCursorMoveDown<cr>", { desc = "Move to split below" })
    vim.keymap.set("n", "<C-k>", "<cmd>SmartCursorMoveUp<cr>", { desc = "Move to split above" })
    vim.keymap.set("n", "<C-l>", "<cmd>SmartCursorMoveRight<cr>", { desc = "Move to right split" })
    -- swapping buffers between windows
    vim.keymap.set("n", "<leader>bH", require("smart-splits").swap_buf_left, { desc = "Swap buffer left" })
    vim.keymap.set("n", "<leader>bJ", require("smart-splits").swap_buf_down, { desc = "Swap buffer down" })
    vim.keymap.set("n", "<leader>bK", require("smart-splits").swap_buf_up, { desc = "Swap buffer up" })
    vim.keymap.set("n", "<leader>bL", require("smart-splits").swap_buf_right, { desc = "Swap buffer right" })
  end,
}
