-- Plugin to guess whether to use tabs or spaces for indents based on the current buffer
return {
  "nmac427/guess-indent.nvim",
  config = function()
    require("guess-indent").setup({})
  end,
}
