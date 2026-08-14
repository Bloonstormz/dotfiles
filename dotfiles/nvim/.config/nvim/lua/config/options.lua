-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

opt.shiftwidth = 4
opt.tabstop = 4
opt.expandtab = false
opt.listchars = "tab:> ,lead:·,trail:-,nbsp:+"

local base_chars = {
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
}

opt.fillchars:append(base_chars)

if vim.fn.executable("zsh") == 1 then
  opt.shell = "zsh"
else
  opt.shell = "bash"
end
