-- ╭─────────────────────────────────────────────────────────╮
-- │ Keymaps Configuration                                   │
-- │ Global keybindings for Neovim                          │
-- ╰─────────────────────────────────────────────────────────╯

-- ─── General ──────────────────────────────────────────────

-- Clear search highlights on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- ─── Diagnostics ──────────────────────────────────────────

-- Open diagnostic quickfix list
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- ─── Terminal ─────────────────────────────────────────────

-- Exit terminal mode with double Esc
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ─── Line Navigation ──────────────────────────────────────

-- Move to the beginning or end of line with H and L
vim.keymap.set({ 'n', 'v' }, 'H', '^', { desc = 'Move beginning of line' })
vim.keymap.set('n', 'L', '$', { desc = 'Move end of line' })
vim.keymap.set('v', 'L', 'g_', { desc = 'Move end of line' })

-- ─── Centered Navigation ─────────────────────────────────

-- Center cursor after jumps for better visibility
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Center cursor after jump' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Center cursor after jump' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Center cursor after jump' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Center cursor after jump' })
