-- Smart Window Management
return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    require("smart-splits").setup({ ---@diagnostic disable-line: missing-fields
      cursor_follows_swapped_bufs = true,
    })
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
  end,
}
