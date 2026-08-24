local open_tool = function(command, root_markers)
  local cwd = vim.fs.root(0, root_markers) or vim.fn.getcwd()
  vim.cmd('botright 12new')
  vim.fn.jobstart(command, { cwd = cwd, term = true })
  vim.cmd.startinsert()
end

vim.api.nvim_create_user_command('CargoMachete', function()
  open_tool({ 'cargo', 'machete' }, { 'Cargo.toml', '.git' })
end, { desc = 'Find unused Cargo dependencies' })

vim.api.nvim_create_user_command('CargoDeny', function()
  open_tool({ 'cargo', 'deny', 'check' }, { 'Cargo.toml', '.git' })
end, { desc = 'Check Cargo dependency policies' })

vim.api.nvim_create_user_command('Knip', function()
  open_tool({ 'pnpm', 'exec', 'knip' }, { 'pnpm-lock.yaml', 'package.json', '.git' })
end, { desc = 'Find unused JavaScript and TypeScript code' })
