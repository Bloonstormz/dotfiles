local function find_function_node(node)
  if not node then
    return nil
  end

  while node do
    if node:type() == "function_declaration" then
      return node
    end
    node = node:parent()
  end

  return nil
end

local function add_no_side_effects_annotation()
  local api = vim.api

  local cursor_node = vim.treesitter.get_node()
  if not cursor_node then
    return
  end

  local func_node = find_function_node(cursor_node)
  if not func_node then
    vim.notify("No function node found under cursor", vim.log.levels.WARN)
    return
  end

  local start_row, _, _, _ = func_node:range()

  -- check if already annotated (avoid duplicates)
  local line_before = api.nvim_buf_get_lines(0, start_row - 1, start_row, false)[1]
  if line_before and line_before:match("@__NO_SIDE_EFFECTS__") then
    vim.notify("Already annotated", vim.log.levels.INFO)
    return
  end

  api.nvim_buf_set_lines(0, start_row, start_row, false, {
    "/* @__NO_SIDE_EFFECTS__ */",
  })
end

vim.keymap.set("n", "<leader>ce", add_no_side_effects_annotation, {
  desc = "Add /* @__NO_SIDE_EFFECTS__ */ notation to the function",
})
