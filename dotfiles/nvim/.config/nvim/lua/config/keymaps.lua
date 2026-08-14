-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local wk = require("which-key")

wk.add({
  mode = "i",
  -- Ctrl+H is the same control character as Ctrl+Backspace
  { "<C-H>", "<C-W>" },
  { "<S-Left>", "<C-O>b" },
  { "<C-Left>", "<C-O>B" },
  { "<S-Right>", "<C-O>e<Right>" },
  { "<C-Right>", "<C-O>E<Right>" },
})
