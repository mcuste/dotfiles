return {
  "folke/snacks.nvim",
  opts = {
    -- Show hidden files by default in the fuzzy picker
    picker = {
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        explorer = { hidden = true },
      },
    },
    -- Show hidden files by default in the file explorer
    explorer = {
      hidden = true,
    },
  },
}
