if vim.env.HERDR_ENV ~= '1' then return end

Config.now(function()
  vim.pack.add({ 'https://github.com/mcuste/herdr-context.nvim' })

  require('herdr-context').setup({
    mappings = {
      buffer = '<leader>aa',
      buffers = '<leader>aA',
      diagnostics = '<leader>ad',
      buffers_diagnostics = '<leader>aD',
      messages = '<leader>am',
      quickfix = '<leader>aq',
      quickfix_all = '<leader>aQ',
      loclist = '<leader>al',
    },
    quickfix = {
      limit = 50,
    },
  })

  vim.list_extend(Config.leader_group_clues, {
    { mode = 'n', keys = '<Leader>a', desc = '+Agent' },
    { mode = 'x', keys = '<Leader>a', desc = '+Agent' },
  })
end)
