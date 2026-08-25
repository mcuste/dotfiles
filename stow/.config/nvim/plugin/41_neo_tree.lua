-- Traditional sidebar tree with Git status and a Git-only change tree.
local add, later = vim.pack.add, Config.later

later(function()
  add({
    { src = 'https://github.com/nvim-neo-tree/neo-tree.nvim', version = vim.version.range('3') },
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
  })

  require('neo-tree').setup({
    enable_git_status = true,
    default_component_configs = {
      indent = { with_markers = true },
      git_status = {
        symbols = {
          added = '✚',
          modified = '●',
          deleted = '✖',
          renamed = '󰁕',
          untracked = '?',
          ignored = '◌',
          unstaged = '✗',
          staged = '✓',
          conflict = '!',
        },
      },
    },
    window = {
      position = 'left',
      width = 36,
      mappings = {
        ['e'] = 'open',
        ['z'] = 'close_all_nodes',
        ['Z'] = 'expand_all_nodes',
      },
    },
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_ignored = false,
      },
      follow_current_file = { enabled = false },
      use_libuv_file_watcher = true,
    },
  })

  Config.new_autocmd('WinClosed', '*', function()
    vim.schedule(function()
      local wins = vim.api.nvim_tabpage_list_wins(0)
      if #wins == 1 and vim.bo[vim.api.nvim_win_get_buf(wins[1])].filetype == 'neo-tree' then
        vim.cmd('quit')
      end
    end)
  end, 'Close file tree when it is the last window')

  local git_path_targets = function(root)
    local result = vim
      .system({ 'git', 'status', '--porcelain=v1', '-z', '--untracked-files=all' }, {
        cwd = root,
        text = false,
      })
      :wait()
    if result.code ~= 0 then
      return {}
    end

    local targets, seen = {}, {}
    local records = vim.split(result.stdout or '', '\0', { plain = true, trimempty = true })
    local i = 1
    while i <= #records do
      local record = records[i]
      local status, path = record:sub(1, 2), record:sub(4)
      if status:find('R', 1, true) or status:find('C', 1, true) then
        i = i + 1
      end

      local target = root .. '/' .. path
      if not (vim.uv or vim.loop).fs_stat(target) then
        target = vim.fs.dirname(target)
      end
      if not seen[target] then
        seen[target] = true
        table.insert(targets, target)
      end
      i = i + 1
    end
    table.sort(targets, function(a, b)
      return #a < #b
    end)
    return targets
  end

  vim.api.nvim_create_user_command('NeoTreeGitPaths', function()
    local root_result = vim.system({ 'git', 'rev-parse', '--show-toplevel' }, { text = true }):wait()
    if root_result.code ~= 0 then
      vim.notify('Current directory is not in a Git repository', vim.log.levels.WARN)
      return
    end

    local root = vim.trim(root_result.stdout)
    local manager = require('neo-tree.sources.manager')
    local state = manager.get_state('filesystem')
    local renderer = require('neo-tree.ui.renderer')
    if renderer.window_exists(state) then
      require('neo-tree.command').execute({ action = 'close', source = 'filesystem', position = 'left' })
      return
    end

    local targets = git_path_targets(root)
    require('neo-tree.command').execute({ action = 'focus', source = 'filesystem', position = 'left', dir = root })

    local filesystem = require('neo-tree.sources.filesystem')
    local commands = require('neo-tree.sources.common.commands')
    local attempts = 0
    local expand_targets
    expand_targets = function()
      if not state.tree and attempts < 20 then
        attempts = attempts + 1
        vim.defer_fn(expand_targets, 50)
        return
      end
      if not state.tree then
        return
      end

      commands.close_all_nodes(state)
      local reveal_next
      reveal_next = function()
        local target = table.remove(targets, 1)
        if target then
          filesystem.navigate(state, root, target, reveal_next)
        end
      end
      reveal_next()
    end
    expand_targets()
  end, {})
end)
