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

    disable_frontmatter = function(fname)
      local path = fname or vim.api.nvim_buf_get_name(0)
      return path:find("%.claude") ~= nil
    end,

    note_frontmatter_func = function(note)
      local path = vim.api.nvim_buf_get_name(0)
      if path:find("%.claude") then
        return note.metadata or {}
      end
      local out = { id = note.id, aliases = note.aliases, tags = note.tags }
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end
      return out
    end,

    wiki_link_func = "use_alias_only",

    picker = {
      name = "snacks.pick",
    },

    ui = {
      enable = false,
    },
  },
}
