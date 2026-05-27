return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = { mason = false },
      },
      setup = {
        gopls = function() end,
      },
    },
  },
}