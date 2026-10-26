local add, later = vim.pack.add, Config.later

-- Linting ====================================================================

later(function()
  add({ 'https://github.com/mfussenegger/nvim-lint' })

  local lint = require('lint')
  lint.linters.selene.args = {
    '--config',
    vim.fn.stdpath('config') .. '/selene.toml',
    '--display-style',
    'json',
    '-',
  }
  lint.linters_by_ft = {
    bash = { 'shellcheck' },
    dockerfile = { 'hadolint' },
    gdscript = { 'gdlint' },
    go = { 'golangcilint' },
    lua = { 'selene' },
    sh = { 'shellcheck' },
    terraform = { 'tflint' },
    yaml = { 'yamllint' },
  }
  Config.new_autocmd({ 'BufReadPost', 'BufWritePost' }, nil, function()
    lint.try_lint()
  end, 'Lint buffer')
end)
