-- ┌──────────────────────────────┐
-- │ Reload files changed on disk │
-- └──────────────────────────────┘
--
-- External tools (LLM agents, formatters, `git checkout`) rewrite files while
-- Neovim keeps them open. Neovim only notices the change when `:checktime`
-- runs, which by default happens on focus and buffer events. That is not enough
-- when Neovim sits in a background pane of a terminal multiplexer, so a timer
-- runs the check too.
--
-- A reload also leaves the language server out of sync for a moment. Inlay
-- hints kept from the old file content then point outside the new lines, and
-- drawing them throws "Invalid 'col': out of range". Resetting the hints after
-- each reload drops the old data and asks the server for new hints.

vim.o.autoread = true -- Reload unmodified buffers when the file changes on disk

-- How often to look for changes on disk, in milliseconds
local check_interval = 1000

-- How long to wait after a reload before asking for new inlay hints
local hint_delay = 250

-- `:checktime` can not run in these modes and would interrupt what you type
local can_check = function()
  if vim.fn.getcmdwintype() ~= '' then return false end
  local mode = vim.api.nvim_get_mode().mode
  return mode == 'n' or mode == 'v' or mode == 'V' or mode == '\22'
end

local check_time = function()
  if can_check() then pcall(vim.cmd.checktime) end
end

Config.new_autocmd(
  { 'BufEnter', 'CursorHold', 'FocusGained', 'TermLeave', 'InsertLeave' },
  nil,
  check_time,
  'Check for file changes on disk'
)

-- Keep the timer in a variable so that it is not garbage collected
local timer = vim.uv.new_timer()
timer:start(check_interval, check_interval, vim.schedule_wrap(check_time))

-- Drop inlay hints computed for the old file content and request new ones.
-- The delay gives the language server time to process the buffer update.
local reset_inlay_hints = function(buf)
  if not vim.api.nvim_buf_is_loaded(buf) then return end
  local filter = { bufnr = buf }
  if not vim.lsp.inlay_hint.is_enabled(filter) then return end
  vim.lsp.inlay_hint.enable(false, filter)
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_loaded(buf) then vim.lsp.inlay_hint.enable(true, filter) end
  end, hint_delay)
end

Config.new_autocmd('FileChangedShellPost', nil, function(ev)
  reset_inlay_hints(ev.buf)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(ev.buf), ':t')
  vim.notify('Reloaded ' .. name, vim.log.levels.INFO)
end, 'Resync LSP state after reload')
