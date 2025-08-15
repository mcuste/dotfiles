return {
  'CopilotC-Nvim/CopilotChat.nvim',
  opts = {
    model = 'claude-sonnet-4',
    context = 'buffers',
    temperature = 0.1,
  },
  keys = {
    { '<c-s>', '<CR>', ft = 'copilot-chat', desc = 'Submit Prompt', remap = true },
    { '<leader>as', ':CopilotChatStop<cr>', desc = 'Stop Chat Output (CopilotChat)' },
    { '<leader>am', ':CopilotChatModels<cr>', desc = 'Chat Models (CopilotChat)' },
    { '<leader>ar', ':CopilotChatReset<cr>', desc = 'Clear (CopilotChat)', mode = { 'n', 'v' } },
    { '<leader>a=', ':tabdo wincmd =<cr>', desc = 'Equalize windows', mode = { 'n', 'v' } },

    {
      '<leader>aa',
      function()
        require('CopilotChat').toggle()
      end,
      desc = 'Toggle (CopilotChat)',
      mode = { 'n', 'v' },
    },

    {
      '<leader>aq',
      function()
        vim.ui.input({
          prompt = 'Quick Chat: ',
        }, function(input)
          if input ~= '' then
            require('CopilotChat').ask(input)
          end
        end)
      end,
      desc = 'Quick Chat (CopilotChat)',
      mode = { 'n', 'v' },
    },

    {
      '<leader>ap',
      function()
        require('CopilotChat').select_prompt()
      end,
      desc = 'Prompt Actions (CopilotChat)',
      mode = { 'n', 'v' },
    },
  },
}

