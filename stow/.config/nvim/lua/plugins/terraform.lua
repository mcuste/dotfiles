return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = { enabled = false },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.terraform = nil
      opts.linters_by_ft.tf = nil
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.sources = vim.tbl_filter(function(s)
        return s.name ~= "terraform_validate"
      end, opts.sources or {})
    end,
  },
}
