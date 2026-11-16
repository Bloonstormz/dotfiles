local height = 10
local width = 69

local version = vim.version()
local version_str = version.major .. "." .. version.minor .. "." .. version.patch

local space_count = width - 5 - string.len(version_str)

return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      width = width,
      sections = {
        {
          section = "terminal",
          cmd = '{cat ~/.config/nvim/logo.txt; echo "'
            .. string.rep(" ", space_count)
            .. version_str
            .. '"} | { command -v lolcat >/dev/null && lolcat -b || cat; }',
          height = height,
          align = "center",
          padding = 0,
        },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
  },
}
