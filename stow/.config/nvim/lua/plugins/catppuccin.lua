return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,

    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      term_colors = true,
      auto_integrations = true,

      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.15,
      },

      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,

        mini = {
          enabled = true,
          indentscope_color = "",
        },

        telescope = {
          enabled = true,
        },

        which_key = true,
        grug_far = true,
        mason = true,
        fidget = true,
        neotest = true,
        dap = true,
        dap_ui = true,

        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
          inlay_hints = { background = true },
        },

        blink_cmp = { style = "bordered" },
        snacks = { enabled = true },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
