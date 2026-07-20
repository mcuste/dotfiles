return {
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources.default = { "lsp", "path", "buffer" }
      opts.keymap["<Tab>"] = { "fallback" }
      opts.keymap["<S-Tab>"] = { "fallback" }
    end,
  },
}
