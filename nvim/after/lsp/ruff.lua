---@type vim.lsp.Config
return {
  cmd = { require("lib.file").script_dir() .. "/../../../.venv/bin/ruff", "server" },
  ---@type lspconfig.settings.ruff
  settings = {},
  filetypes = { "python" },
  root_markers = { ".git" },
}
