-- ╭─────────────────────────────────────────────────────────╮
-- │ Autocmds Configuration                                  │
-- │ Automatic commands that run on specific events          │
-- ╰─────────────────────────────────────────────────────────╯

-- ─── File Management ──────────────────────────────────────

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'Check if file needs reloading when it was changed externally',
  group = vim.api.nvim_create_augroup('checktime', { clear = true }),
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd 'checktime'
    end
  end,
})

-- ─── Window Management ────────────────────────────────────

-- Resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  desc = 'Resize splits when the window is resized',
  group = vim.api.nvim_create_augroup('resize-splits', { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd 'tabdo wincmd ='
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- ─── Buffer Navigation ────────────────────────────────────

-- Go to last location when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Go to last location when opening a buffer',
  group = vim.api.nvim_create_augroup('last-location', { clear = true }),
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ─── Quick Close Buffers ──────────────────────────────────

-- Close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close certain filetypes with <q>',
  group = vim.api.nvim_create_augroup('close-with-q', { clear = true }),
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns.blame',
    'grug-far',
    'help',
    'lspinfo',
    'notify',
    'qf',
    'query',
    'spectre_panel',
    'startuptime',
    'tsplayground',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', {
      buffer = event.buf,
      silent = true,
      desc = 'Quit buffer',
    })
  end,
})

-- ─── Buffer List Management ───────────────────────────────

-- Make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Make man pages unlisted in buffer list',
  group = vim.api.nvim_create_augroup('man-unlisted', { clear = true }),
  pattern = { 'man' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- ─── Text File Settings ───────────────────────────────────

-- Wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable wrap and spell check for text files',
  group = vim.api.nvim_create_augroup('wrap-spell', { clear = true }),
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- ─── JSON Settings ────────────────────────────────────────

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'Disable concealing for JSON files',
  group = vim.api.nvim_create_augroup('json-conceal', { clear = true }),
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- ─── Directory Creation ───────────────────────────────────

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  desc = 'Auto create parent directories when saving a file',
  group = vim.api.nvim_create_augroup('auto-create-dir', { clear = true }),
  callback = function(event)
    if event.match:match '^%w%w+:[\\/][\\/]' then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- ─── Filetype Specific Settings ──────────────────────────

-- Fix terraform and hcl comment string
vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'Fix terraform and hcl comment string',
  group = vim.api.nvim_create_augroup('fix-tf-commentstring', { clear = true }),
  pattern = { 'terraform', 'hcl' },
  callback = function(ev)
    vim.bo[ev.buf].commentstring = '# %s'
  end,
})

-- Note: Terminal insert mode and highlight yanking are handled by mini.basics
