-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
Config.now(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  local ts_update = function()
    vim.cmd('TSUpdate')
  end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  local languages = {
    'bash',
    'css',
    'dockerfile',
    'gdscript',
    'go',
    'gomod',
    'gosum',
    'gowork',
    'hcl',
    'html',
    'javascript',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'rust',
    'terraform',
    'toml',
    'tsx',
    'typescript',
    'vimdoc',
    'yaml',
  }
  local treesitter = require('nvim-treesitter')
  treesitter.setup()
  local needs_install = function(lang)
    local parser = #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0
    local query = #vim.api.nvim_get_runtime_file('queries/' .. lang .. '/highlights.scm', false) > 0
    return not (parser and query)
  end
  local to_install = vim.tbl_filter(needs_install, languages)
  if #to_install > 0 then
    treesitter.install(to_install, { force = true }):wait(300000)
  end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev)
    vim.treesitter.start(ev.buf)
  end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================

now_if_args(function()
  vim.g.rustaceanvim = {
    server = {
      default_settings = {
        ['rust-analyzer'] = {
          check = { command = 'clippy', extraArgs = { '--all-targets' } },
        },
      },
    },
  }

  add({
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/b0o/SchemaStore.nvim',
    { src = 'https://github.com/mrcjkb/rustaceanvim', version = vim.version.range('^9') },
    { src = 'https://github.com/Saecki/crates.nvim', version = vim.version.range('^0.7') },
  })

  require('crates').setup()

  vim.lsp.config('gopls', {
    settings = {
      gopls = {
        completeUnimported = true,
        gofumpt = true,
        staticcheck = true,
        analyses = { nilness = true, shadow = true, unusedparams = true, unusedwrite = true, useany = true },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  })
  vim.lsp.config('pyright', {
    settings = {
      pyright = { disableOrganizeImports = true },
      python = { analysis = { diagnosticMode = 'workspace', typeCheckingMode = 'standard' } },
    },
  })
  vim.lsp.config('ruff', {
    on_attach = function(client)
      client.server_capabilities.hoverProvider = false
    end,
  })
  local typescript_lib
  local tsserver = vim.fn.exepath('tsserver')
  if tsserver ~= '' and vim.fn.filereadable(tsserver) == 1 then
    for _, line in ipairs(vim.fn.readfile(tsserver)) do
      local target = line:match('^# cmd%-shim%-target=(.+)/bin/tsserver$')
      if target then
        typescript_lib = target .. '/lib'
      end
    end
  end
  local ts_inlay_hints = {
    includeInlayEnumMemberValueHints = true,
    includeInlayFunctionLikeReturnTypeHints = true,
    includeInlayFunctionParameterTypeHints = true,
    includeInlayParameterNameHints = 'all',
    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
    includeInlayPropertyDeclarationTypeHints = true,
    includeInlayVariableTypeHints = true,
    includeInlayVariableTypeHintsWhenTypeMatchesName = true,
  }
  vim.lsp.config('ts_ls', {
    init_options = typescript_lib and { tsserver = { path = typescript_lib } } or nil,
    settings = {
      javascript = { inlayHints = ts_inlay_hints },
      typescript = { inlayHints = ts_inlay_hints },
    },
  })
  vim.lsp.config('bashls', {
    settings = { bashIde = { shellcheckPath = 'shellcheck' } },
  })

  local schemastore = require('schemastore')
  vim.lsp.config('jsonls', {
    settings = {
      json = { schemas = schemastore.json.schemas(), validate = { enable = true } },
    },
  })
  vim.lsp.config('yamlls', {
    settings = {
      yaml = {
        format = { enable = true },
        schemaStore = { enable = false, url = '' },
        schemas = schemastore.yaml.schemas({
          extra = {
            {
              name = 'Kubernetes',
              description = 'Kubernetes manifests',
              url = 'kubernetes',
              fileMatch = { '*.k8s.yaml', '*.k8s.yml', 'k8s/**/*.yaml', 'kubernetes/**/*.yaml', 'manifests/**/*.yaml' },
            },
          },
        }),
        validate = true,
      },
    },
  })

  Config.new_autocmd('LspAttach', nil, function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/inlayHint', ev.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end, 'Enable LSP inlay hints')

  vim.lsp.enable({
    'lua_ls',
    'pyright',
    'ruff',
    'gopls',
    'ts_ls',
    'biome',
    'eslint',
    'jsonls',
    'html',
    'cssls',
    'tailwindcss',
    'gdscript',
    'terraformls',
    'taplo',
    'yamlls',
    'helm_ls',
    'dockerls',
    'docker_compose_language_service',
    'bashls',
  })
end)

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
