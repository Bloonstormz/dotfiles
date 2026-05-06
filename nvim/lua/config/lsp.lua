vim.lsp.config.bashls = {
  cmd = { "bash-language-server", "start" },
  filetypes = { "bash", "sh" },
  settings = {
    bashIde = {
      includeAllWorkspaceSymbols = true,
    },
  },
}

vim.lsp.enable("bashls")
