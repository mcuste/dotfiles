-- Git Blame
return {
  {
    "f-person/git-blame.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitblame").setup({
        enabled = true,
        message_template = "  <date> • <author> • <summary>",
        date_format = "%r",
        max_commit_summary_length = 60,
        ignored_filetypes = { "help", "qf", "fugitive" },
      })

      vim.keymap.set("n", "<leader>gt", "<cmd>GitBlameToggle<cr>", { desc = "Toggle Blame" })
    end,
  },
}
