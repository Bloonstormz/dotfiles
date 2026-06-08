-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
-- Ctrl+H is the same control character as Ctrl+Backspace
keymap.set("i", "<C-H>", "<C-W>")
