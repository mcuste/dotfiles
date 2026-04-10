return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  ft = "markdown",

  cmd = { "ObsidianToday", "ObsidianNew", "ObsidianSearch" },
  keys = {
    { "<leader>o", group = "obsidian" },
    { "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Daily Note" },
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Note" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Notes" },
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/Projects/personal/notes",
      },
    },

    notes_subdir = "capture",

    daily_notes = {
      folder = "logs",
      date_format = "%Y/%m/%Y-%m-%d",
      template = "daily.md",
    },

    templates = {
      folder = "_templates",
    },

    completion = {
      nvim_cmp = false,
      min_chars = 2,
    },

    new_notes_location = "notes_subdir",

    wiki_link_func = "use_alias_only",

    picker = {
      name = "snacks.pick",
    },

    ui = {
      enable = false,
    },
  },
}
