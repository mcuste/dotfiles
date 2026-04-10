local root_term = nil

return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = {
    direction = "float",
    float_opts = { border = "rounded" },
  },
  keys = {
    {
      "<leader>t",
      function()
        local Terminal = require("toggleterm.terminal").Terminal
        if not root_term then
          root_term = Terminal:new({ dir = LazyVim.root(), count = 99 })
        end
        root_term:toggle()
      end,
      desc = "Terminal (root dir)",
    },
    {
      "<leader>T",
      "<cmd>ToggleTerm<cr>",
      desc = "Terminal (cwd)",
    },
    {
      "<leader>T",
      "<cmd>ToggleTerm<cr>",
      mode = "t",
      desc = "Toggle terminal",
    },
  },
}
