if vim.env.HERDR_ENV ~= '1' then return end

Config.now(function()
  vim.pack.add({ 'https://github.com/lmilojevicc/herdr-splits.nvim' })

  local herdr_splits = require('herdr-splits')
  herdr_splits.setup()

  vim.keymap.set('n', '<C-h>', herdr_splits.move_cursor_left, { desc = 'Navigate left' })
  vim.keymap.set('n', '<C-j>', herdr_splits.move_cursor_down, { desc = 'Navigate down' })
  vim.keymap.set('n', '<C-k>', herdr_splits.move_cursor_up, { desc = 'Navigate up' })
  vim.keymap.set('n', '<C-l>', herdr_splits.move_cursor_right, { desc = 'Navigate right' })
  vim.keymap.set('n', '<M-h>', herdr_splits.resize_left, { desc = 'Resize left' })
  vim.keymap.set('n', '<M-j>', herdr_splits.resize_down, { desc = 'Resize down' })
  vim.keymap.set('n', '<M-k>', herdr_splits.resize_up, { desc = 'Resize up' })
  vim.keymap.set('n', '<M-l>', herdr_splits.resize_right, { desc = 'Resize right' })
end)
