return {
  "MagicDuck/grug-far.nvim",
  keys = {
    { "<leader>sr", false }, -- Remove default sr binding
    {
      "<leader>fr",
      function()
        local grug = require("grug-far")
        local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
        grug.open({
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
          },
        })
      end,
      desc = "Find and Replace",
    },
  },
}