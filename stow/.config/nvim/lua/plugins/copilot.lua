return {
  'zbirenbaum/copilot.lua',
  opts = {
    filetypes = {
      yaml = true,
      markdown = true,
      gitcommit = true,
    },
    server_opts_overrides = {
      capabilities = {
        general = {
          positionEncodings = { 'utf-8' },
        },
      },
    },
  },
}