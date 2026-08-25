if vim.env.HERDR_ENV ~= '1' then return end

Config.now(function()
  vim.pack.add({ 'https://github.com/mcuste/herdr-context.nvim' })

  require('herdr-context').setup({
    mappings = {
      buffer = '<leader>ac',
      selection = '<leader>ac',
    },
  })
end)
