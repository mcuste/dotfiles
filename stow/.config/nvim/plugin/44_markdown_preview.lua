-- Browser preview with automatic updates for Markdown buffers.
-- The install hook must sit in 'init.lua', before the first `vim.pack.add()` call.
vim.pack.add({ 'https://github.com/iamcco/markdown-preview.nvim' })
vim.cmd('runtime plugin/mkdp.vim')
