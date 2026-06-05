-- Utility functions relating to files

return {
  script_dir = function()
    local script_path = vim.uv.fs_realpath(debug.getinfo(2, "S").source:sub(2))
    if script_path == nil then
      return nil
    end
    return vim.fs.dirname(script_path)
  end,
}
