return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "asm" },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "asm-lsp" },
    },
  },
}
