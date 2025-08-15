return {
  'ruifm/gitlinker.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  keys = {
    {
      '<leader>gy',
      function()
        require('gitlinker').get_buf_range_url 'n'
      end,
      desc = 'Copy git link',
      mode = 'n',
    },
    {
      '<leader>gy',
      function()
        require('gitlinker').get_buf_range_url 'v'
      end,
      desc = 'Copy git link (range)',
      mode = 'v',
    },
    {
      '<leader>gY',
      function()
        require('gitlinker').get_repo_url()
      end,
      desc = 'Copy repo URL',
      mode = 'n',
    },
    {
      '<leader>go',
      function()
        require('gitlinker').get_buf_range_url('n', {
          action_callback = function(url)
            -- Copy to clipboard
            vim.fn.setreg('+', url)
            -- Open in browser (macOS)
            vim.fn.jobstart({ 'open', url }, { detach = true })
            vim.notify('Opened: ' .. url)
          end,
        })
      end,
      desc = 'Open git link in browser',
      mode = 'n',
    },
    {
      '<leader>go',
      function()
        require('gitlinker').get_buf_range_url('v', {
          action_callback = function(url)
            -- Copy to clipboard
            vim.fn.setreg('+', url)
            -- Open in browser (macOS)
            vim.fn.jobstart({ 'open', url }, { detach = true })
            vim.notify('Opened: ' .. url)
          end,
        })
      end,
      desc = 'Open git link in browser (range)',
      mode = 'v',
    },
    {
      '<leader>gO',
      function()
        require('gitlinker').get_repo_url {
          action_callback = function(url)
            -- Copy to clipboard
            vim.fn.setreg('+', url)
            -- Open in browser (macOS)
            vim.fn.jobstart({ 'open', url }, { detach = true })
            vim.notify('Opened: ' .. url)
          end,
        }
      end,
      desc = 'Open repo URL in browser',
      mode = 'n',
    },
  },
  config = function()
    require('gitlinker').setup {
      remote = nil, -- auto-detect remote
      add_current_line_on_normal_mode = true,
      action_callback = require('gitlinker.actions').copy_to_clipboard,
      print_url = true,
      mappings = nil, -- disable default mappings since we define our own
    }
  end,
}