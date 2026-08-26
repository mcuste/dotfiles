-- Git signs ==================================================================

Config.later(function()
  vim.pack.add({ 'https://github.com/lewis6991/gitsigns.nvim' })

  require('gitsigns').setup({
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '▁' },
      topdelete = { text = '▔' },
      changedelete = { text = '▎' },
      untracked = { text = '▎' },
    },
  })
end)
