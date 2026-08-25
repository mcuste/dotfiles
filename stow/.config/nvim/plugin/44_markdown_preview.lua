-- Browser preview with automatic updates for Markdown buffers.
local install_preview = function()
  vim.fn['mkdp#util#install']()
end
Config.on_packchanged('markdown-preview.nvim', { 'install', 'update' }, install_preview, 'Install Markdown preview')

vim.pack.add({ 'https://github.com/iamcco/markdown-preview.nvim' })
vim.cmd('runtime plugin/mkdp.vim')
