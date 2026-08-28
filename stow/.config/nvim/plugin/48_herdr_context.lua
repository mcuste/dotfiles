if vim.env.HERDR_ENV ~= '1' then return end

Config.now(function()
  vim.pack.add({
    { src = 'https://github.com/mcuste/herdr-context.nvim', version = vim.version.range('^1') },
  })

  require('herdr-context').setup({
    mappings = {
      buffer = '<Leader>ab',
      buffers = '<Leader>aB',
      diagnostics = '<Leader>ad',
      buffers_diagnostics = '<Leader>aD',
    },
  })
end)
