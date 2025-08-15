return {
  'MagicDuck/grug-far.nvim',
  enabled = not vim.g.vscode,
  keys = {
    {
      '<leader>r',
      function()
        local grug = require 'grug-far'
        local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
        grug.open {
          transient = true,
          prefills = {
            filesFilter = ext and ext ~= '' and ('*.' .. ext) or nil,
          },
        }
      end,
      mode = { 'n', 'v' },
      desc = 'Search and Replace',
    },
  },
}