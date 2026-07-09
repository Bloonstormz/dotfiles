vim.api.nvim_create_user_command("W", "write", {
  desc = "Write",
})

local function copy_to_clipboard(text)
  vim.fn.setreg("+", text)
  vim.notify("Copied '" .. text .. "' to the clipboard")
end

vim.api.nvim_create_user_command("CopyPath", function()
  local path = vim.fn.expand("%:p")
  copy_to_clipboard(path)
end, {
  desc = "Copy Absolute Path of Current Buffer",
})

vim.api.nvim_create_user_command("CopyRelPath", function()
  local path = vim.fn.expand("%:.")
  copy_to_clipboard(path)
end, {
  desc = "Copy Relative Path of Current Buffer",
})
