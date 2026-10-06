local M = {}

function M.remove_item(t, item)
  for k, v in ipairs(t) do
    if v == item then
      table.remove(t, k)
    end
  end
end

return M
