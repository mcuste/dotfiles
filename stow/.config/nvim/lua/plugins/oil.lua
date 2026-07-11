return {
  "stevearc/oil.nvim",
  keys = {
    {
      "<leader>e",
      function()
        require("oil").open(vim.uv.cwd())
      end,
      desc = "File Explorer (oil)",
    },
  },
  opts = {},
}
