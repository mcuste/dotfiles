return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  config = function()
    require("smart-splits").setup({
      ignored_filetypes = {
        "nofile",
        "quickfix",
        "qf",
        "prompt",
      },
      ignored_buftypes = { "nofile" },
      default_amount = 3,
      at_edge = "wrap",
    })

    -- Navigation keybindings for tmux integration
    vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Move cursor left" })
    vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Move cursor down" })
    vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Move cursor up" })
    vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Move cursor right" })

    -- Resize keybindings
    vim.keymap.set("n", "<M-h>", require("smart-splits").resize_left, { desc = "Resize left" })
    vim.keymap.set("n", "<M-j>", require("smart-splits").resize_down, { desc = "Resize down" })
    vim.keymap.set("n", "<M-k>", require("smart-splits").resize_up, { desc = "Resize up" })
    vim.keymap.set("n", "<M-l>", require("smart-splits").resize_right, { desc = "Resize right" })

    -- Swapping buffers between windows (keep custom keybindings)
    vim.keymap.set("n", "<leader>bh", require("smart-splits").swap_buf_left, { desc = "Swap buffer left" })
    vim.keymap.set("n", "<leader>bj", require("smart-splits").swap_buf_down, { desc = "Swap buffer down" })
    vim.keymap.set("n", "<leader>bk", require("smart-splits").swap_buf_up, { desc = "Swap buffer up" })
    vim.keymap.set("n", "<leader>bl", require("smart-splits").swap_buf_right, { desc = "Swap buffer right" })
  end,
}
