return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
      defaults = {
        autocmds = true, -- lazyvim.config.autocmds
        keymaps = false, -- lazyvim.config.keymaps - don't need it
        options = true, -- lazyvim.config.options
      },
    },
  },

  { "persistence.nvim", enabled = false },
  { "noice.nvim", enabled = false },
  { "flash.nvim", enabled = false },
  { "gitsigns.nvim", enabled = false },
  { "trouble.nvim", enabled = false },
  { "todo-comments.nvim", enabled = false },
  { "tokyonight.nvim", enabled = false },

  {
    "snacks.nvim",
    opts = {
      bigfile = { enabled = true },
      explorer = { enabled = false },
      image = { enabled = true },
      input = { enabled = false },
      picker = { enabled = true },
      notifier = { enabled = false },
      quickfile = { enabled = true },
      rename = { enabled = true },
      scope = { enabled = false },
      scroll = { enabled = false },
      words = { enabled = false },
    },
    keys = { -- Disable / Change Keymaps for Snacks
      -- notifier
      { "<leader>n", false }, -- notifier
      { "<leader>un", false }, -- notifier

      -- pickers
      { "<leader>n", false }, -- Notification History
      { "<leader>fc", false }, -- Find Config File
      { "<leader>fp", false }, -- Projects
      { "<leader>sp", false }, -- Search for Plugin Spec
      { '<leader>s"', false }, -- Registers
      { "<leader>sa", false }, -- Autocmds
      { "<leader>sh", false }, -- Help Pages
      { "<leader>sH", false }, -- Highlights
      { "<leader>si", false }, -- Icons
      { "<leader>sj", false }, -- Jumps
      { "<leader>sk", false }, -- Keymaps
      { "<leader>sl", false }, -- Location List
      { "<leader>sM", false }, -- Man Pages
      { "<leader>sm", false }, -- marks
      { "<leader>su", false }, -- undo tree
      { "<leader>uC", false }, -- colorschemes
      { "<leader>fb", false }, -- Buffers | duplicate of '<leader>,' one
      { "<leader>ff", false }, -- Find Files (Root Dir) | duplicate of '<leader><leader>'
      { "<leader>fF", false }, -- Find Files (cwd) | no need
      { "<leader>fg", false }, -- Find Files (git-files) | no need
      { "<leader>gs", false }, -- Git Status | no need
      { "<leader>gS", false }, -- Git Stash | no need
      { "<leader>sg", false }, -- Grep (Root Dir) | duplicate of '<leader>/'
      { "<leader>sG", false }, -- Grep (cwd) | no need
      { "<leader>sW", false }, -- Visual selection or word (cwd) | no need
      { "<leader>s/", false }, -- Search History | no need
      { "<leader>sc", false }, -- Command History | duplicate of '<leader>:'
    },
  },

  { import = "lazyvim.plugins.extras.editor.mini-move" },
  {
    "mini.move",
    opts = {
      mappings = {
        -- Move visual selection in Visual mode
        left = "<A-S-h>",
        down = "<A-S-j>",
        up = "<A-S-k>",
        right = "<A-S-l>",

        -- Move current line in Normal mode
        line_left = "<A-S-h>",
        line_down = "<A-S-j>",
        line_up = "<A-S-k>",
        line_right = "<A-S-l>",
      },
    },
  },

  { import = "lazyvim.plugins.extras.editor.mini-diff" },
  { import = "lazyvim.plugins.extras.editor.mini-files" },

  { import = "lazyvim.plugins.extras.coding.mini-surround" },
  { import = "lazyvim.plugins.extras.coding.mini-comment" },
  { import = "lazyvim.plugins.extras.coding.mini-snippets" },
  { import = "lazyvim.plugins.extras.coding.neogen" },

  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.dap.nlua" },

  { import = "lazyvim.plugins.extras.test.core" },

  { import = "lazyvim.plugins.extras.ai.copilot" },
  { import = "lazyvim.plugins.extras.ai.copilot-chat" },

  { import = "lazyvim.plugins.extras.util.dot" },
  { import = "lazyvim.plugins.extras.util.mini-hipatterns" },

  -- ------------------------------------------------------ Langs
  { import = "lazyvim.plugins.extras.formatting.prettier" },
  { import = "lazyvim.plugins.extras.linting.eslint" },
  { import = "lazyvim.plugins.extras.lang.git" },
  { import = "lazyvim.plugins.extras.lang.sql" },
  { import = "lazyvim.plugins.extras.lang.toml" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.lang.tailwind" },
  { import = "lazyvim.plugins.extras.lang.astro" },
  { import = "lazyvim.plugins.extras.lang.vue" },
  { import = "lazyvim.plugins.extras.lang.svelte" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.cmake" },
  { import = "lazyvim.plugins.extras.lang.rust" },
  { import = "lazyvim.plugins.extras.lang.go" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.ansible" },
  { import = "lazyvim.plugins.extras.lang.terraform" },
  { import = "lazyvim.plugins.extras.lang.docker" },
  { import = "lazyvim.plugins.extras.lang.helm" },
  { import = "lazyvim.plugins.extras.lang.yaml" },
}
