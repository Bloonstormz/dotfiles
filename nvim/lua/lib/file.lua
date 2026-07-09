-- Utility functions relating to files

local M = {}
local dotfile_dir = nil

function M:script_dir()
  local script_path = vim.uv.fs_realpath(debug.getinfo(2, "S").source:sub(2))
  if script_path == nil then
    return nil
  end
  return vim.fs.dirname(script_path)
end

function M:dotfile_dir()
  if dotfile_dir == nil then
    local lib_dir = self:script_dir()
    local lua_dir = vim.fs.dirname(lib_dir)
    local nvim_dir = vim.fs.dirname(lua_dir)
    dotfile_dir = vim.fs.dirname(nvim_dir)
  end

  return dotfile_dir
end

function M:lsp_dir()
  return self:dotfile_dir() .. "/downloads/lsp"
end

return M
