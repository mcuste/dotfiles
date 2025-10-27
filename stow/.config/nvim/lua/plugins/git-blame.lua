-- Git Blame
return {
  {
    "f-person/git-blame.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitblame").setup({
        enabled = true,
        message_template = "  <date> • <author> • <summary>",
        date_format = "%Y-%m-%d",
      })
      vim.keymap.set("n", "<leader>gt", "<cmd>GitBlameToggle<cr>", { desc = "Toggle Blame" })
    end,
  },
}
