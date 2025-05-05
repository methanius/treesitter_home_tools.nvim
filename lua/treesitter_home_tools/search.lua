local ts = vim.treesitter

local M = {}
---Find the next node result from query input.
---If standing on a node result, get the last position of it
---@param tree TSTree
---@param query vim.treesitter.Query
---@param opts SearchOpts
---@return TSNode?
function M.get_next_queried_node(tree, query, opts)
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  for _, node, _ in
    query:iter_captures(tree:root(), vim.api.nvim_get_current_buf(), cursor_line - 1, -1)
  do
    local _, start_col, end_row, end_col = node:range()
    if opts.include_current then
      if end_row + 1 > cursor_line or (end_row + 1 == cursor_line and end_col > cursor_col) then
        return node
      end
    else
      if end_row + 1 > cursor_line or (end_row + 1 == cursor_line and start_col > cursor_col) then
        return node
      end
    end
  end
end

---Find the previous node result from query input.
---If standing on a node result, get the last position of it
---@param tree TSTree
---@param query vim.treesitter.Query
---@param opts SearchOpts
---@return TSNode?
function M.get_previous_queried_node(tree, query, opts)
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local ret_node = nil
  for _, node, _ in query:iter_captures(tree:root(), vim.api.nvim_get_current_buf(), 0, cursor_line) do
    local start_row, start_col, _, end_col = node:range()
    if opts.include_current then
      if
        start_row + 1 < cursor_line
        or (start_row + 1 == cursor_line and start_col < cursor_col)
      then
        ret_node = node
      end
    else
      if start_row + 1 < cursor_line or (start_row + 1 == cursor_line and end_col < cursor_col) then
        ret_node = node
      end
    end
  end
  return ret_node
end

return M
