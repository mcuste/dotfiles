Config.now(function()
  vim.pack.add({ 'https://github.com/linrongbin16/gitlinker.nvim' })

  require('gitlinker').setup()

  vim.keymap.set({ 'n', 'v' }, '<leader>gy', '<cmd>GitLink<cr>', { desc = 'Copy Git link' })
  vim.keymap.set({ 'n', 'v' }, '<leader>gY', '<cmd>GitLink!<cr>', { desc = 'Open Git link' })
end)
