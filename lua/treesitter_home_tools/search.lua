local M = {}
---Find the next node result from query input.
---If standing on a node result, get the last position of it
---@param tree TSTree
---@param query vim.treesitter.Query
---@return TSNode?
function M.get_next_queried_node(tree, query)
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local _, node, _ = vim.iter(query:iter_captures(tree:root(), vim.api.nvim_get_current_buf(), cursor_line - 1, -1))
      :next()
  return node
end

---Find the previous node result from query input.
---If standing on a node result, get the last position of it
---@param tree TSTree
---@param query vim.treesitter.Query
---@return TSNode?
function M.get_previous_queried_node(tree, query)
  local cursor_line, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local nodes = vim.iter(query:iter_captures(tree:root(), vim.api.nvim_get_current_buf(), 0, cursor_line))
  local extracted_nodes = nodes:map(function(_, node, _) return node end)
  return extracted_nodes:last()
end

return M
