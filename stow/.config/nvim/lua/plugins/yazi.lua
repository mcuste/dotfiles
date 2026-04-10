return {
  "mikavilpas/yazi.nvim",
  dependencies = { "folke/snacks.nvim" },
  keys = {
    {
      "<leader>e",
      function()
        require("yazi").yazi(nil, vim.fn.getcwd())
      end,
      desc = "File Explorer (yazi)",
    },
  },
  opts = {
    open_for_directories = true,
    yazi_floating_window_border = "double",
    keymaps = {
      open_file_in_tab = false,
    },
    hooks = {
      on_yazi_ready = function(buffer, config, process_api)
        vim.schedule(function()
          vim.keymap.set({ "t" }, "<c-t>", function()
            local helpers = require("yazi.keybinding_helpers")
            helpers.select_current_file_and_close_yazi(config, {
              api = process_api,
              on_file_opened = function(chosen_file)
                vim.cmd("ClaudeCodeAdd " .. vim.fn.fnameescape(chosen_file))
              end,
              on_multiple_files_opened = function(chosen_files)
                for _, file in ipairs(chosen_files) do
                  vim.cmd("ClaudeCodeAdd " .. vim.fn.fnameescape(file))
                end
              end,
            })
          end, { buffer = buffer })
        end)
      end,
    },
    integrations = {
      grep_in_directory = "snacks.picker",
      grep_in_selected_files = "snacks.picker",
    },
  },
}
