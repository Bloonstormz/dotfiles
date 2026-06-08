vim.keymap.set("n", "<Leader>gM", function()
  vim.cmd("vsplit")
  vim.cmd("Man")
end, {
  buffer = true,
  desc = "Open Man page with vertical split",
})

-- <C-H> is the same control character as <C-BS>
vim.keymap.set("n", "<C-H>", "<C-T>")
