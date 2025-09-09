-- Bootstrap
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- ================================ CORE SETTINGS =================================
-- Leader Keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Global Variables

-- Display Options
vim.o.termguicolors = true -- True color support
vim.o.relativenumber = true -- Relative line numbers
vim.o.scrolloff = 10 -- Keep 10 lines above/below cursor
vim.o.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
vim.o.laststatus = 3 -- Global statusline
vim.o.guicursor = 'n-v-c-i:block' -- Block cursor in all modes
vim.o.list = true -- Show invisible characters
vim.o.conceallevel = 0 -- Conceal text (for markdown, etc.)

-- Editor Behavior
vim.o.clipboard = 'unnamedplus' -- System clipboard integration
vim.o.updatetime = 250 -- Faster file change detection (default 4000ms)
vim.o.timeoutlen = 300 -- Time to wait for mapped sequence
vim.o.inccommand = 'split' -- Preview substitutions live
vim.o.confirm = true -- Confirm to save changes before exiting
vim.o.autowrite = true -- Auto-save before commands like :next
vim.o.autoread = true -- Auto-reload files when changed outside vim
vim.o.swapfile = false -- Disable swap files
vim.o.undolevels = 100 -- Number of undo levels
vim.o.spell = false -- Disable spell checking by default

-- Indentation
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.tabstop = 4 -- Tab width
vim.o.shiftwidth = 2 -- Indent width
vim.o.shiftround = true -- Round indent to multiple of shiftwidth
vim.o.formatoptions = 'jcroqlnt' -- Format options for text

-- Folding
vim.o.foldmethod = 'expr' -- Use expression for folding
vim.o.foldexpr = 'nvim_treesitter#foldexpr()' -- Treesitter-based folding
vim.o.foldenable = false -- Don't fold by default

-- Auto-quit certain filetypes with 'q'
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'help', 'qf', 'quickfix', 'loclist', 'man', 'lspinfo', 'checkhealth' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

-- =============================== CORE KEYMAPS ==================================
-- Quick line navigation
vim.keymap.set({ 'n', 'x' }, 'H', '^', { desc = 'Move to beginning of line' })
vim.keymap.set({ 'n', 'x' }, 'L', '$', { desc = 'Move to end of line' })

-- Center cursor after page movements
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Page down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Page up and center' })

-- Center cursor after search navigation
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result and center' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result and center' })

-- Save file with Ctrl+s
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>', { desc = 'Save file' })

-- Custom reload command
vim.api.nvim_create_user_command('ReloadConf', function()
  vim.cmd('source ' .. vim.fn.stdpath 'config' .. '/init.lua')
  print 'Config reloaded!'
end, { desc = 'Reload Neovim configuration' })

-- ============================== PLUGIN SETUP ===================================
require('lazy').setup {
  { 'echasnovski/mini.basics', priority = 1000, opts = {} },
  { 'echasnovski/mini.starter', priority = 1000, opts = {} },
  { 'echasnovski/mini.statusline', priority = 1000, opts = {} },
  { 'echasnovski/mini.tabline', priority = 1000, opts = {} },
  { 'echasnovski/mini.diff', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.ai', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.pairs', event = 'InsertEnter', opts = {} },
  { 'echasnovski/mini.splitjoin', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.surround', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.bracketed', event = 'VeryLazy', opts = {} },
  { 'echasnovski/mini.indentscope', event = { 'BufReadPre', 'BufNewFile' }, opts = {} },

  {
    'echasnovski/mini.bufremove',
    opts = {},
    keys = { { '<leader>bd', '<cmd>lua MiniBufremove.delete()<cr>', desc = 'Delete Buffer' } },
  },

  {
    'echasnovski/mini.icons',
    priority = 1000,
    config = function()
      require('mini.icons').setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },

  {
    'echasnovski/mini.move',
    event = 'VeryLazy',
    config = function()
      require('mini.move').setup {
        mappings = {
          -- Move visual selection (Shift + Alt + hjkl)
          left = '<S-M-h>',
          right = '<S-M-l>',
          down = '<S-M-j>',
          up = '<S-M-k>',
          -- Move current line in Normal mode
          line_left = '<S-M-h>',
          line_right = '<S-M-l>',
          line_down = '<S-M-j>',
          line_up = '<S-M-k>',
        },
      }
    end,
  },

  {
    'echasnovski/mini.comment',
    event = 'VeryLazy',
    config = function()
      require('mini.comment').setup {
        options = {
          custom_commentstring = function()
            local ok, ts_context = pcall(require, 'ts_context_commentstring.internal')
            if ok then
              return ts_context.calculate_commentstring() or vim.bo.commentstring
            end
            return vim.bo.commentstring
          end,
        },
      }
    end,
  },

  {
    'echasnovski/mini.files',
    opts = {},
    -- stylua: ignore
    keys = { { '<leader>e', function() MiniFiles.open() end, desc = 'Open file explorer' } },
  },

  -- Highlight patterns (TODO, FIXME, colors, etc.)
  {
    'echasnovski/mini.hipatterns',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'echasnovski/mini.extra' },
    config = function()
      local hi_words = require('mini.extra').gen_highlighter.words
      local hipatterns = require 'mini.hipatterns'
      hipatterns.setup {
        highlighters = {
          -- Highlight code annotations
          todo = hi_words({ 'TODO' }, 'MiniHipatternsTodo'),
          note = hi_words({ 'NOTE' }, 'MiniHipatternsNote'),
          fixme = hi_words({ 'FIXME' }, 'MiniHipatternsFixme'),
          hack = hi_words({ 'HACK' }, 'MiniHipatternsFixme'),
          -- Highlight hex colors with their actual color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      }
    end,
  },

  -- Which-key hints
  {
    'echasnovski/mini.clue',
    event = 'VeryLazy',
    config = function()
      local miniclue = require 'mini.clue'
      miniclue.setup {
        window = { delay = 400 },
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },
          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },
          -- `g` key
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },
          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },
          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },
          -- Window commands
          { mode = 'n', keys = '<C-w>' },
          -- `z` key
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
        },

        clues = {
          -- Built-in clues
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.z(),

          -- Custom leader groups
          { mode = 'n', keys = '<leader>b', desc = '+buffer' },
          { mode = 'n', keys = '<leader>c', desc = '+code' },
          { mode = 'n', keys = '<leader>d', desc = '+debug' },
          { mode = 'n', keys = '<leader>f', desc = '+find' },
          { mode = 'n', keys = '<leader>g', desc = '+git' },
          { mode = 'n', keys = '<leader>r', desc = '+rename' },
          { mode = 'n', keys = '<leader>w', desc = '+workspace' },
        },
      }
    end,
  },

  -- Colorscheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      -- Configure Catppuccin with integration support
      require('catppuccin').setup {
        flavour = 'mocha', -- Options: latte, frappe, macchiato, mocha
        background = {
          light = 'latte',
          dark = 'mocha',
        },
        integrations = {
          grug_far = true,
          treesitter = true,
          mason = true,
          fidget = true,
          neotest = true,
          dap = true,
          dap_ui = true,
          native_lsp = { enabled = true },
          blink_cmp = { style = 'bordered' },
          mini = {
            enabled = true,
            indentscope_color = 'lavender',
          },
        },
      }

      -- Apply colorscheme
      vim.cmd 'colorscheme catppuccin'
    end,
  },

  -- Guess Indentation
  {
    'nmac427/guess-indent.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  -- Git Blame
  {
    'f-person/git-blame.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('gitblame').setup {
        enabled = false,
        message_template = '  <date> • <author> • <summary>',
        date_format = '%Y-%m-%d',
      }
      vim.keymap.set('n', '<leader>gB', '<cmd>GitBlameToggle<cr>', { desc = 'Toggle Blame' })
    end,
  },

  -- Gitignore Generator
  { 'wintermute-cell/gitignore.nvim', opts = {}, cmd = 'Gitignore' },

  -- Smart Window Management
  {
    'mrjones2014/smart-splits.nvim',
    version = 'v1.6.0',
    event = 'VeryLazy',
    config = function()
      require('smart-splits').setup {
        ignored_buftypes = { 'nofile', 'quickfix', 'prompt' },
        ignored_filetypes = { 'NvimTree' },
        default_amount = 3,
        at_edge = 'wrap',
        move_cursor_same_row = false,
      }

      -- Resizing splits
      vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left, { desc = 'Resize split left' })
      vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down, { desc = 'Resize split down' })
      vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up, { desc = 'Resize split up' })
      vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right, { desc = 'Resize split right' })

      -- Moving between splits
      vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left, { desc = 'Move to left split' })
      vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down, { desc = 'Move to bottom split' })
      vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up, { desc = 'Move to top split' })
      vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right, { desc = 'Move to right split' })

      -- Swapping buffers between windows (using <leader>b instead of <leader><leader>)
      vim.keymap.set('n', '<leader>bh', require('smart-splits').swap_buf_left, { desc = 'Swap buffer left' })
      vim.keymap.set('n', '<leader>bj', require('smart-splits').swap_buf_down, { desc = 'Swap buffer down' })
      vim.keymap.set('n', '<leader>bk', require('smart-splits').swap_buf_up, { desc = 'Swap buffer up' })
      vim.keymap.set('n', '<leader>bl', require('smart-splits').swap_buf_right, { desc = 'Swap buffer right' })
    end,
  },

  -- Fuzzy Finder
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      local telescope = require 'telescope'
      local builtin = require 'telescope.builtin'

      -- Telescope configuration
      telescope.setup {
        defaults = {
          layout_config = { prompt_position = 'top' },
          sorting_strategy = 'ascending',
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
          -- stylua: ignore
          file_ignore_patterns = {
            '.git/', 'node_modules/', 'venv/', 'env/', '.venv/',
            '__pycache__/', '%.pyc', 'dist/', 'build/', '%.o',
            '%.a', '%.out', '%.class', '%.pdf', '%.mkv', '%.mp4',
            '%.zip',
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Load extensions
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      -- ─────────────────────── Telescope Keymaps ──────────────────
      -- File and text search
      vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = 'Pickers' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Files' })
      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Grep Word' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Grep' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Diagnostics' })
      vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = 'Find Recent Files' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
      vim.keymap.set('n', '<leader>:', builtin.command_history, { desc = 'Command History' })
      vim.keymap.set('n', '<leader>fh', builtin.search_history, { desc = 'Search History' })
      vim.keymap.set('n', '<leader><leader>', builtin.resume, { desc = 'Resume' })

      -- Current buffer search
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Grep Current Buffer' })

      -- Search in open files
      vim.keymap.set('n', '<leader>f/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Grep in Open Files',
        }
      end, { desc = 'Find in Open Files' })

      -- Git integration
      vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Git Files' })
      vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git Commits' })
      vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Git Branches' })
    end,
  },

  -- Tree sitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
      'windwp/nvim-ts-autotag',
    },
    config = function()
      require('nvim-treesitter.configs').setup {
        auto_install = true, -- Automatically install missing parsers when entering buffer (requires tree-sitter-cli)
        highlight = { enable = true },
      }

      -- Setup context-aware commentstring
      require('ts_context_commentstring').setup {
        enable_autocmd = false,
      }

      -- Setup ts auto tags
      require('nvim-ts-autotag').setup {}
    end,
  },

  -- Code completion with blink.cmp and snippets
  {
    'saghen/blink.cmp',
    version = 'v1.6.0',
    dependencies = {
      'rafamadriz/friendly-snippets',
      'echasnovski/mini.snippets',
    },
    opts = {
      keymap = { preset = 'default' },
      signature = { enabled = true },
      snippets = { preset = 'mini_snippets' },

      sources = {
        -- add lazydev to completion providers
        default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            -- make lazydev completions top priority (see `:h blink.cmp`)
            score_offset = 100,
          },
        },
      },

      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        menu = {
          draw = {
            components = {
              kind_icon = {
                text = function(ctx)
                  local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                  return kind_icon
                end,
                highlight = function(ctx)
                  local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                  return hl
                end,
              },
              kind = {
                highlight = function(ctx)
                  local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                  return hl
                end,
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      -- Setup mini.snippets first
      local gen_loader = require('mini.snippets').gen_loader
      require('mini.snippets').setup {
        snippets = {
          -- Load custom global snippets
          gen_loader.from_file '~/.config/nvim/snippets/global.json',
          -- Load language-specific snippets
          gen_loader.from_lang(),
        },
      }

      require('blink.cmp').setup(opts)
    end,
  },

  -- Code Annotation Generator
  { 'danymat/neogen', cmd = 'Neogen', config = true },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'j-hui/fidget.nvim',
      'folke/lazydev.nvim',
    },
    config = function()
      -- Setup Mason first (must be loaded before dependents)
      require('mason').setup()

      -- Setup fidget for LSP status updates
      require('fidget').setup {}

      -- Setup lazydev for Lua development
      require('lazydev').setup {
        library = {
          -- Load luvit types when the `vim.uv` word is found
          { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
      }

      -- Helper function to check client capabilities across Neovim versions
      local function client_supports_method(client, method, bufnr)
        if vim.fn.has 'nvim-0.11' == 1 then
          return client:supports_method(method, bufnr)
        else
          return client.supports_method(method, { bufnr = bufnr })
        end
      end

      -- LSP Attach autocmd (kickstart-style)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local builtin = require 'telescope.builtin'

          -- Helper function for buffer-local keymaps
          local function map(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Kickstart-style keymaps
          map('grn', vim.lsp.buf.rename, 'Rename')
          map('gra', vim.lsp.buf.code_action, 'Code Action', { 'n', 'x' })
          map('grr', builtin.lsp_references, 'References')
          map('gri', builtin.lsp_implementations, 'Implementation')
          map('grd', builtin.lsp_definitions, 'Definition')
          map('grD', vim.lsp.buf.declaration, 'Declaration')
          map('gO', builtin.lsp_document_symbols, 'Document Symbols')
          map('gW', builtin.lsp_dynamic_workspace_symbols, 'Workspace Symbols')
          map('grt', builtin.lsp_type_definitions, 'Type Definition')
          map('gl', vim.diagnostic.open_float, 'Line Diagnostics')

          -- Get the client for capability checking
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          -- Document highlighting
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- Inlay hints toggle (kickstart-style)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            -- Enable inlay hints by default
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

            map('<leader>ch', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, 'Toggle Inlay Hints')
          end
        end,
      })

      -- Diagnostic configuration (kickstart-style)
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        },
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- Get LSP capabilities from blink.cmp
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- Language servers configuration (kickstart-style)
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure tools are installed
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      -- Setup mason-lspconfig
      require('mason-lspconfig').setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- Code linting with nvim-lint
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
      }

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then
            lint.try_lint()
          end
        end,
      })
    end,
  },

  -- Code formatting with conform.nvim
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = 'fallback', -- not recommended to change
      },
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- Conform can also run multiple formatters sequentially
        -- python = { "isort", "black" },
        --
        -- You can use 'stop_after_first' to run the first available formatter from the list
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
    config = function(_, opts)
      require('conform').setup(opts)
      -- Format keymap
      vim.keymap.set({ 'n', 'v' }, '<leader>cf', function() -- TODO: doesn't work?
        require('conform').format { async = true, lsp_format = 'fallback' }
      end, { desc = 'Format' })
    end,
  },

  -- Debug Adapter Protocol (DAP) configuration for debugging support
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      -- Language-specific debuggers
      'leoluz/nvim-dap-go',
    },
    -- stylua: ignore
    keys = {
      { '<leader>dc', function() require('dap').continue() end, desc = 'Debug: Start/Continue' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
      { '<leader>do', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
      { '<leader>dO', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Debug: Toggle Breakpoint' },
      {'<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Set Conditional Breakpoint'},
      { '<leader>du', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },
      { '<leader>dr', function() require('dap').repl.open() end, desc = 'Debug: Open REPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = 'Debug: Run Last' },
      { '<leader>dt', function() require('dap').terminate() end, desc = 'Debug: Terminate' },
      { '<leader>dgt', function() require('dap-go').debug_test() end, desc = 'Debug: Go Test' },
      { '<leader>dgl', function() require('dap-go').debug_last_test() end, desc = 'Debug: Go Last Test' },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- Setup mason-nvim-dap for automatic debugger installation
      require('mason-nvim-dap').setup {
        automatic_installation = true,
        handlers = {},
        ensure_installed = {
          'delve', -- Go debugger
        },
      }

      -- DAP UI setup with clean icons
      dapui.setup {
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      -- Auto-open/close DAP UI
      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Go Debug Adapter (Delve)
      require('dap-go').setup {
        delve = {
          -- On Windows delve must be run attached or it crashes
          detached = vim.fn.has 'win32' == 0,
        },
      }
    end,
  },

  -- Language-specific configurations

  -- Rust support with rustaceanvim
  {
    'mrcjkb/rustaceanvim',
    version = '^6', -- Recommended
    ft = { 'rust' },
    init = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
              },
              -- checkOnSave = {
              --   command = 'clippy',
              -- },
            },
          },
        },
      }
    end,
  },
}
