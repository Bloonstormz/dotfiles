---@type lspconfig.settings.ruff
local ruff_settings = {
  lint = {
    -- Ignore requiring module imports at top of file.
    -- Sometimes I need to modify the PATH variable before importing
    ignore = { "E402" },
  },
}

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ruff = {
        mason = false,
        settings = {
          cmd = { "ruff", "server" },
          init_options = {
            settings = ruff_settings,
          },
          settings = ruff_settings,
          filetypes = { "python" },
          root_markers = { ".git" },
        },
      },
      bashls = {
        ---@type lspconfig.settings.bashls
        settings = {
          bashIde = {
            includeAllWorkspaceSymbols = true,
            shellcheckArguments = "-e SC1090",
          },
        },
      },
    },
  },
}
