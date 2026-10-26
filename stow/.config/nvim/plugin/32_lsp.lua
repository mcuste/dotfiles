local add, now_if_args = vim.pack.add, Config.now_if_args

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
    { src = 'https://github.com/Saecki/crates.nvim',  version = vim.version.range('^0.7') },
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
  local typescript_language_server_cmd = function(dispatchers, config)
    local root_dir = config.root_dir or vim.fn.getcwd()
    local node_modules = vim.fs.joinpath(root_dir, 'node_modules')
    local local_server = vim.fs.joinpath(node_modules, '.bin', 'typescript-language-server')
    local local_tsc = vim.fs.joinpath(node_modules, '.bin', 'tsc')
    local tsserver = vim.fs.joinpath(node_modules, 'typescript', 'lib', 'tsserver.js')
    local cmd
    if vim.uv.fs_stat(local_tsc) and not vim.uv.fs_stat(tsserver) then
      cmd = { local_tsc, '--lsp', '--stdio' }
    elseif vim.uv.fs_stat(local_server) and vim.uv.fs_stat(tsserver) then
      cmd = { local_server, '--stdio' }
    else
      cmd = { 'tsc', '--lsp', '--stdio' }
    end
    return vim.lsp.rpc.start(cmd, dispatchers, { cwd = root_dir })
  end
  vim.lsp.config('ts_ls', {
    cmd = typescript_language_server_cmd,
    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
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
      -- Disable first to drop hints kept from a previous run of the server
      vim.lsp.inlay_hint.enable(false, { bufnr = ev.buf })
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
