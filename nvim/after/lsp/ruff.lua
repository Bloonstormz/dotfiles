---@type lspconfig.settings.ruff
local settings = {
  lint = {
    -- Ignore requiring module imports at top of file.
    -- Sometimes I need to modify the PATH variable before importing
    ignore = { "E402" },
  },
}

---@type vim.lsp.Config
return {
  cmd = { require("lib.file"):lsp_dir() .. "/ruff", "server" },
  init_options = {
    settings = settings,
  },
  ---@type lspconfig.settings.ruff
  settings = settings,
  filetypes = { "python" },
  root_markers = { ".git" },
}
