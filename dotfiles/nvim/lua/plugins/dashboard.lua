-- Note: This assumes that the lolcat version being used is: https://github.com/jaseg/lolcat

local height = 10
local width = 69

local version = vim.version()
local version_str = version.major .. "." .. version.minor .. "." .. version.patch

local space_count = width - 5 - string.len(version_str)

local lolcat_cmd
if vim.opt.termguicolors then
  lolcat_cmd = "lolcat -b"
else
  lolcat_cmd = "lolcat"
end

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
            .. '"} | { command -v lolcat >/dev/null && '
            .. lolcat_cmd
            .. " || cat; }",
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
