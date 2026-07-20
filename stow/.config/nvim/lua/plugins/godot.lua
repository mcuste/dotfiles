local dap_default_keys = {
  "<leader>dB",
  "<leader>db",
  "<leader>dc",
  "<leader>da",
  "<leader>dC",
  "<leader>dg",
  "<leader>di",
  "<leader>dj",
  "<leader>dk",
  "<leader>dl",
  "<leader>do",
  "<leader>dO",
  "<leader>dP",
  "<leader>dr",
  "<leader>ds",
  "<leader>dt",
  "<leader>dw",
}

local disabled_dap_keys = {}
for _, key in ipairs(dap_default_keys) do
  disabled_dap_keys[#disabled_dap_keys + 1] = { key, false }
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gdscript = { mason = false },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gdscript", "godot_resource", "gdshader" })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        gdscript = { "gdformat" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        gdscript = { "gdlint" },
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    keys = vim.list_extend(disabled_dap_keys, {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/continue" },
      { "<F6>", function() require("dap").terminate() end, desc = "Debug: Stop" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step into" },
      { "<S-F11>", function() require("dap").step_out() end, desc = "Debug: Step out" },
    }),
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gdscript",
        once = true,
        callback = function()
          local dap = require("dap")
          dap.adapters.godot = {
            type = "server",
            host = "127.0.0.1",
            port = 6006,
          }
          dap.configurations.gdscript = {
            {
              type = "godot",
              request = "launch",
              name = "Debug Godot project",
              project = "${workspaceFolder}",
              launch_scene = true,
            },
          }
        end,
      })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    keys = {
      { "<leader>du", false },
      { "<leader>de", false },
      { "<F8>", function() require("dapui").toggle({}) end, desc = "Debug: Toggle UI" },
      { "<S-F8>", function() require("dapui").eval() end, mode = { "n", "x" }, desc = "Debug: Evaluate" },
    },
  },
}
