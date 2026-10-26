local add, later = vim.pack.add, Config.later

-- Formatting =================================================================

later(function()
  add({ 'https://github.com/stevearc/conform.nvim' })

  local web = { 'biome-check', 'prettier', stop_after_first = true }
  require('conform').setup({
    default_format_opts = { lsp_format = 'fallback' },
    format_on_save = { timeout_ms = 2000, lsp_format = 'fallback' },
    formatters_by_ft = {
      bash = { 'shfmt' },
      css = web,
      gdscript = { 'gdformat' },
      go = { 'goimports', 'gofumpt' },
      html = web,
      javascript = web,
      javascriptreact = web,
      json = web,
      jsonc = web,
      lua = { 'stylua' },
      markdown = { 'prettier' },
      python = { 'ruff_organize_imports', 'ruff_format' },
      rust = { 'rustfmt' },
      sh = { 'shfmt' },
      terraform = { 'terraform_fmt' },
      toml = { 'taplo' },
      typescript = web,
      typescriptreact = web,
      yaml = { 'yamlfmt' },
      ['yaml.docker-compose'] = { 'yamlfmt' },
    },
  })
end)
