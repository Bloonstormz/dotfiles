return {
  {
    "mfussenegger/nvim-lint",
    -- Disable markdown linter as I don't like the max length rule.
    -- TODO: Figure out how to configure that rule from nvim config rather
    -- than a manual config file per repository
    opts = function(_, opts)
      opts = opts or {}

      if opts.linters_by_ft.markdown ~= nil then
        opts.linters_by_ft.markdown = nil
      end

      return opts
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}

      if opts.ensure_installed then
        require("lib.util").remove_item(opts.ensure_installed, "markdownlint-cli2")
      end
    end,
  },
}
