-- Disable diagnostics in markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.diagnostic.enable(false, { bufnr = ev.buf })
  end,
})

-- TODO: find good way to render markdown
return {
  -- Disable browser-based markdown preview
  { "iamcco/markdown-preview.nvim" },
  -- Disable in-editor markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        width = "block",
        left_pad = 1,
        right_pad = 1,
      },
    },
  },
}
