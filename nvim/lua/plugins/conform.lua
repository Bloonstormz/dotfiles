return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters = opts.formatters or {}
    opts.formatters["biome-check"] = {
      require_cwd = false,
    }
  end,
}
