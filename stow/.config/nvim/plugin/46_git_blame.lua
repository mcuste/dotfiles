Config.now(function()
  vim.pack.add({ 'https://github.com/f-person/git-blame.nvim' })

  require('gitblame').setup({
    enabled = true,
    message_template = '  <date> • <author> • <summary>',
    date_format = '%r',
    max_commit_summary_length = 60,
    ignored_filetypes = { 'help', 'qf', 'fugitive' },
  })

  vim.keymap.set('n', '<leader>gt', '<cmd>GitBlameToggle<cr>', { desc = 'Toggle blame' })
end)
