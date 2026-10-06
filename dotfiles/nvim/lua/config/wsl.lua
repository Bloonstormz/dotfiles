-- General Settings for running nvim in wsl

local clip_path = "/mnt/c/Windows/System32/clip.exe"
local powershell_path = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
local powershell_get_clipboard = powershell_path
  .. ' -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))'

if vim.fn.has("wsl") == 1 then
  -- Copy to clipboard
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = clip_path,
      ["*"] = clip_path,
    },

    paste = {
      ["+"] = powershell_get_clipboard,
      ["*"] = powershell_get_clipboard,
    },
    cache_enabled = 0,
  }
end
