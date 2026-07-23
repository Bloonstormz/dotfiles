local mason_require = {
  vtsls = "npm",
  biome = "npm",
  pyright = "npm",
  ["tailwindcss-language-server"] = "npm",
  ["json-lsp"] = "npm",
  ["bash-language-server"] = "npm",
  clangd = "unzip",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "python",
        "c",
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "ast-grep")

      local new_installed = {}

      for _, v in ipairs(opts.ensure_installed) do
        local requirement = mason_require[v]
        if requirement == nil or vim.fn.executable(requirement) then
          table.insert(new_installed, v)
        end
      end
    end,
  },
}
