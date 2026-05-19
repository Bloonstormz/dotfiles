local function is_win()
  return package.config:sub(1, 1) == "\\"
end

local function get_path_separator()
  if is_win() then
    return "\\"
  end
  return "/"
end

local function script_path()
  local str = debug.getinfo(2, "S").source:sub(2)
  if is_win() then
    str = str:gsub("/", "\\")
  end
  return str:match("(.*" .. get_path_separator() .. ")")
end

---@type vim.lsp.Config
return {
  cmd = { script_path() .. "../../../.venv/bin/ruff", "server" },
  ---@type lspconfig.settings.ruff
  settings = {},
  filetypes = { "python" },
  root_markers = { ".git" },
}
