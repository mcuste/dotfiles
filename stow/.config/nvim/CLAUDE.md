# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Neovim configuration using Lazy.nvim as the plugin manager. The configuration follows a modular structure with automatic plugin loading and focuses on minimal, efficient setup with LSP, completion, and fuzzy finding capabilities.

## Key Commands

### Development & Testing
- Format current buffer: `<leader>f` (uses conform.nvim, auto-formats on save for most filetypes)
- Check Lua syntax: `stylua --check lua/` (formatter configured in `.stylua.toml`)
- Format Lua files: `stylua lua/`
- View plugin info: `:Lazy` (opens Lazy.nvim dashboard)
- Update plugins: `:Lazy update`
- Check LSP status: `:LspInfo`
- View conform formatters: `:ConformInfo`

### Common Keybindings
- Leader key: `<space>`
- Find files: `<leader>ff`
- Live grep: `<leader>fg`
- Find buffers: `<leader>fb`
- Resume last search: `<leader><leader>`
- Format buffer: `<leader>f`
- LSP rename: `grn`
- LSP code action: `gra`
- LSP go to definition: `grd`
- Toggle inlay hints: `<leader>th`

## Architecture & Structure

### Plugin System
The configuration uses Lazy.nvim with automatic plugin discovery. All plugin specifications are in `lua/plugins/` and are automatically loaded by Lazy. Each file returns a plugin spec or array of specs.

### Core Components

**Initialization Flow:**
1. `init.lua` - Entry point, loads config modules in order
2. `lua/config/options.lua` - Vim options and settings
3. `lua/config/keymaps.lua` - Global keymappings
4. `lua/config/autocmds.lua` - Auto commands
5. `lua/config/lazy.lua` - Bootstrap and configure Lazy.nvim

**Plugin Architecture:**
- `lua/plugins/` - Each file defines one or more plugin specs
- Plugins use lazy loading with `event`, `ft`, `cmd`, and `keys` triggers
- Dependencies are handled automatically by Lazy.nvim

**Key Plugins:**
- **mini.nvim**: Provides core functionality (basics, icons, pairs, surround, ai, comment)
- **blink.cmp**: Modern completion engine with LSP integration
- **telescope.nvim**: Fuzzy finder for files, grep, LSP symbols
- **nvim-lspconfig**: LSP server configurations with Mason for auto-installation
- **conform.nvim**: Code formatting with format-on-save
- **nvim-treesitter**: Syntax highlighting and code folding
- **catppuccin**: Color scheme (Mocha variant)

### Configuration Patterns

**Plugin Definition Pattern:**
```lua
return {
  'plugin/name',
  dependencies = { 'dep1', 'dep2' },
  event = 'VimEnter',  -- or ft = 'lua', cmd = 'Command', keys = {...}
  opts = { ... },      -- or config = function() ... end
}
```

**LSP Server Configuration:**
- Servers defined in `lua/plugins/lsp.lua` in the `servers` table
- Mason automatically installs LSP servers
- Capabilities extended with blink.cmp integration

**Formatting Configuration:**
- Formatters defined in `lua/plugins/conform.lua` under `formatters_by_ft`
- Format-on-save enabled by default (except C/C++)
- Timeout: 500ms with LSP fallback

## Important Notes

- Uses spaces for indentation (2 spaces default, 4 for tab display)
- Stylua configured for single quotes, no call parentheses
- Folding uses treesitter expressions (starts with folds open)
- System clipboard integration enabled
- Block cursor in all modes
- Mini.nvim provides many core features (pairs, surround, comment, etc.)
- Diagnostic signs use Nerd Font icons when available