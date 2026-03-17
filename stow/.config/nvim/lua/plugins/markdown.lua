-- Disable diagnostics in markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.diagnostic.enable(false, { bufnr = ev.buf })
  end,
})

return {
  -- Disable browser-based markdown preview
  { "iamcco/markdown-preview.nvim", enabled = false },
  -- Disable in-editor markdown rendering
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
}
