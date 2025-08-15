return {
  'echasnovski/mini.nvim',
  config = function()
    -- TODO: add snippets?
    require('mini.basics').setup()

    require('mini.ai').setup { n_lines = 500 }
    require('mini.bracketed').setup()
    require('mini.bufremove').setup()

    require('mini.clue').setup {
      triggers = {
        -- Leader triggers
        { mode = 'n', keys = '<Leader>' },
        { mode = 'x', keys = '<Leader>' },

        -- Built-in completion
        { mode = 'i', keys = '<C-x>' },

        -- g key
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

        -- z key
        { mode = 'n', keys = 'z' },
        { mode = 'x', keys = 'z' },

        -- Bracketed
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
      },

      clues = {
        -- Leader groups
        { mode = 'n', keys = '<Leader>a', desc = '+AI' },
        { mode = 'n', keys = '<Leader>b', desc = '+buffer' },
        { mode = 'n', keys = '<Leader>f', desc = '+find' },
        { mode = 'n', keys = '<Leader>g', desc = '+git' },
        { mode = 'n', keys = '<Leader>l', desc = '+lsp' },
        { mode = 'n', keys = '<Leader>t', desc = '+toggle' },

        -- Include mini.clue's generated clues
        require('mini.clue').gen_clues.builtin_completion(),
        require('mini.clue').gen_clues.g(),
        require('mini.clue').gen_clues.marks(),
        require('mini.clue').gen_clues.registers(),
        require('mini.clue').gen_clues.windows(),
        require('mini.clue').gen_clues.z(),
      },

      window = {
        delay = 0, -- Same as which-key delay = 0
        config = {
          width = 'auto',
        },
      },
    }

    require('mini.comment').setup {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring').calculate_commentstring() or vim.bo.commentstring
        end,
      },
    }

    require('mini.diff').setup {
      view = {
        style = 'sign',
        signs = {
          add = '+',
          change = '~',
          delete = '_',
        },
      },
      mappings = {
        apply = '<leader>ga', -- Apply/stage hunk
        reset = '<leader>gA', -- Reset hunk
        textobject = 'gh', -- Text object for hunks
        goto_first = '[H',
        goto_prev = '[h',
        goto_next = ']h',
        goto_last = ']H',
      },
    }

    require('mini.extra').setup()

    require('mini.files').setup {
      windows = {
        preview = true,
        width_preview = 50,
      },
    }
    vim.keymap.set('n', '<leader>e', function()
      require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
    end, { desc = 'Open file explorer' })

    require('mini.git').setup()

    local hipatterns = require 'mini.hipatterns'
    hipatterns.setup {
      highlighters = {
        -- Highlight TODO patterns with colon (but not trailing spaces)
        todo = { pattern = '()TODO:()', group = 'MiniHipatternsTodo' },
        fixme = { pattern = '()FIXME:()', group = 'MiniHipatternsFixme' },
        hack = { pattern = '()HACK:()', group = 'MiniHipatternsHack' },
        note = { pattern = '()NOTE:()', group = 'MiniHipatternsNote' },
        warning = { pattern = '()WARNING:()', group = 'MiniHipatternsFixme' },
        bug = { pattern = '()BUG:()', group = 'MiniHipatternsFixme' },
        perf = { pattern = '()PERF:()', group = 'MiniHipatternsNote' },
        test = { pattern = '()TEST:()', group = 'MiniHipatternsNote' },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    }

    require('mini.icons').setup()
    -- Mock nvim-web-devicons for compatibility with telescope and other plugins
    MiniIcons.mock_nvim_web_devicons()

    require('mini.indentscope').setup()

    require('mini.jump').setup()

    require('mini.move').setup {
      mappings = {
        -- Move visual selection in Visual mode
        left = '<A-S-h>',
        down = '<A-S-j>',
        up = '<A-S-k>',
        right = '<A-S-l>',

        -- Move current line in Normal mode
        line_left = '<A-S-h>',
        line_down = '<A-S-j>',
        line_up = '<A-S-k>',
        line_right = '<A-S-l>',
      },
    }

    require('mini.pairs').setup()
    require('mini.splitjoin').setup()
    require('mini.surround').setup()
    require('mini.tabline').setup()

    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end
  end,
}
