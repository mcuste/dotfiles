return {
  "folke/snacks.nvim",
  opts = {
    explorer = { enabled = false },

    -- Show hidden files by default in the fuzzy picker
    picker = {
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
      },
    },
  },

  keys = {
    { "<leader>K", "<cmd>norm! K<cr>", desc = "Keywordprg" },
    { "<leader>sj", false }, -- Jumps
    { "<leader>si", false }, -- Icons
    { "<leader>sk", false }, -- Keymaps
    { "<leader>sa", false }, -- Autocmds
    { "<leader>sp", false }, -- Search for Plugin Spec
    { "<leader>sR", false }, -- Registers
    { "<leader>sm", false }, -- Marks
    { "<leader>sM", false }, -- Man Pages
    { "<leader>sH", false }, -- Highlights
    { "<leader>sh", false }, -- Help Pages
    { "<leader>n", false }, -- Notification History (replaced by <leader>nh)
    { "<leader>un", false }, -- Dismiss All Notifications (replaced by <leader>nd)
    { "<leader>fR", false }, -- Recent (cwd) — removed
    { "<leader>fF", false }, -- Find files (root dir) — use <leader><leader> instead
    { "<leader>fe", false }, -- Explorer (root dir), use <leader>e instead
    { "<leader>fE", false }, -- Explorer (cwd)
    { "<leader>E", false }, -- Explorer (cwd)
    { "<leader>sg", false }, -- Grep (root dir) — use <leader>/ instead
    { "<leader>sG", false }, -- Grep (cwd) — use <leader>fg instead
    { "<leader>sw", false }, -- moved to <leader>fw
    { "<leader>sW", false }, -- moved to <leader>fW
    { "<leader>s/", false }, -- moved to <leader>f/
    { "<leader>ss", false }, -- moved to <leader>fs
    { "<leader>sS", false }, -- moved to <leader>fS
    { "<leader>sb", false }, -- moved to <leader>fb
    { "<leader>sB", false }, -- Grep Open Buffers
    { "<leader>sc", false }, -- moved to <leader>fc
    { "<leader>sC", false }, -- Commands
    { "<leader>sd", false }, -- Diagnostics
    { "<leader>sD", false }, -- Buffer Diagnostics
    { "<leader>su", false }, -- Undotree
    {
      "<leader>ff",
      function()
        Snacks.picker.files({ cwd = vim.uv.cwd() })
      end,
      desc = "Find Files (cwd)",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.grep({ cwd = vim.uv.cwd() })
      end,
      desc = "Grep (cwd)",
    },
    { "<leader>e", false }, -- Explorer (disabled, use yazi instead)
    {
      "<leader>ft",
      function()
        Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
      end,
      desc = "Todo/Fix/Fixme",
    },
    { "<leader>fw", LazyVim.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
    { "<leader>fW", LazyVim.pick("grep_word", { root = false }), desc = "Visual selection or word (cwd)", mode = { "n", "x" } },
    {
      "<leader>f/",
      function()
        Snacks.picker.search_history()
      end,
      desc = "Search History",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.lines()
      end,
      desc = "Buffer Lines",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>fS",
      function()
        Snacks.picker.lsp_workspace_symbols({ filter = LazyVim.config.kind_filter })
      end,
      desc = "LSP Workspace Symbols",
    },
  },
}
