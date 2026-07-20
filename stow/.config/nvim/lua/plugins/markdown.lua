-- Disable diagnostics in markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(ev)
    vim.diagnostic.enable(false, { bufnr = ev.buf })
  end,
})

-- TODO: find good way to render markdown
return {
  { "iamcco/markdown-preview.nvim" },
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false },
}
