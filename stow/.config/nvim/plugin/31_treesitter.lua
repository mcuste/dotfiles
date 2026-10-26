local add = vim.pack.add

-- Load before FileType events so highlighting works on the first file.
Config.now(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  local ts_update = function()
    vim.cmd('TSUpdate')
  end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  local languages = {
    'bash',
    'css',
    'dockerfile',
    'gdscript',
    'go',
    'gomod',
    'gosum',
    'gowork',
    'hcl',
    'html',
    'javascript',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'rust',
    'terraform',
    'toml',
    'tsx',
    'typescript',
    'vimdoc',
    'yaml',
  }
  local treesitter = require('nvim-treesitter')
  treesitter.setup()
  local needs_install = function(lang)
    local parser = #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) > 0
    local query = #vim.api.nvim_get_runtime_file('queries/' .. lang .. '/highlights.scm', false) > 0
    return not (parser and query)
  end
  local to_install = vim.tbl_filter(needs_install, languages)
  if #to_install > 0 then
    treesitter.install(to_install, { force = true }):wait(300000)
  end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev)
    vim.treesitter.start(ev.buf)
  end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)
