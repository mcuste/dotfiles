return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },

  config = function()
    local pane_id = nil

    local function pane_alive()
      if not pane_id then
        return false
      end
      local out = vim.fn.system("tmux list-panes -a -F '#{pane_id}' 2>/dev/null")
      return out:find(pane_id, 1, true) ~= nil
    end

    local function build_cmd(cmd_string, env_table)
      local parts = {}
      if env_table then
        for k, v in pairs(env_table) do
          parts[#parts + 1] = k .. "=" .. vim.fn.shellescape(v)
        end
      end
      parts[#parts + 1] = cmd_string
      return table.concat(parts, " ")
    end

    local function open_or_focus(cmd_string, env_table, effective_config)
      if pane_alive() then
        vim.fn.system({ "tmux", "select-pane", "-t", pane_id })
        return
      end
      local full_cmd = build_cmd(cmd_string, env_table)
      local size = math.floor((effective_config.split_width_percentage or 0.4) * 100)
      local result = vim.fn.system({
        "tmux",
        "split-window",
        "-h",
        "-l",
        size .. "%",
        "-P",
        "-F",
        "#{pane_id}",
        full_cmd,
      })
      local id = result:gsub("\n", "")
      pane_id = id ~= "" and id or nil
    end

    local tmux_provider = {
      setup = function(_) end,

      is_available = function()
        return vim.fn.executable("tmux") == 1 and os.getenv("TMUX") ~= nil
      end,

      open = function(cmd_string, env_table, effective_config, _focus)
        open_or_focus(cmd_string, env_table, effective_config)
      end,

      close = function()
        if pane_alive() then
          vim.fn.system({ "tmux", "kill-pane", "-t", pane_id })
        end
        pane_id = nil
      end,

      simple_toggle = function(cmd_string, env_table, effective_config)
        open_or_focus(cmd_string, env_table, effective_config)
      end,

      focus_toggle = function(cmd_string, env_table, effective_config)
        open_or_focus(cmd_string, env_table, effective_config)
      end,

      get_active_bufnr = function()
        return nil
      end,
    }

    require("claudecode").setup({ ---@diagnostic disable-line: missing-fields
      terminal = {
        provider = tmux_provider,
      },
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        tmux_provider.close()
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "netrw" },
      callback = function(ev)
        vim.keymap.set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", {
          desc = "Add file",
          buffer = ev.buf,
        })
      end,
    })
  end,

  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    {
      "<leader>ab",
      function()
        require("claudecode").send_at_mention(vim.api.nvim_buf_get_name(0), nil, nil, "ClaudeCodeAdd")
      end,
      desc = "Add current buffer",
    },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}
