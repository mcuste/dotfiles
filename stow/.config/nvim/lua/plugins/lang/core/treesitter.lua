return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'diff',
        'bash',
        'c',
        'lua',
        'luadoc',
        'html',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'rust',
        'toml',
      },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = { enable = true },
    },
  },
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    event = 'VeryLazy',
    opts = { enable_autocmd = false },
  },
}