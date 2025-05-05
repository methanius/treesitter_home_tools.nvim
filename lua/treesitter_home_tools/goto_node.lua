local M = {}

---Almost stolen verbatim from nvim-treesitter/nvim-treesitter
---@param node TSNode TSNode target
---@param goto_end boolean true -> Go to end of node, false -> go to start
---@param avoid_set_jump boolean true -> Do not populate jump list
function M.goto_node(node, goto_end, avoid_set_jump)
  if node == nil then
    return
  end
  if not avoid_set_jump then
    vim.cmd("normal! m'")
  end
  local node_row_start, node_col_start, node_row_end, node_col_end = node:range()
  ---@type {row: number, col: number}
  local target_position
  if not goto_end then
    target_position = { row = node_row_start, col = node_col_start }
  else
    target_position = { row = node_row_end, col = node_col_end - 1 }
  end

  --Enter visual mode if we are in operator pending mode
  --else jump will miss last character
  local mode = vim.api.nvim_get_mode()
  if mode.mode == "no" then
    vim.cmd("normal! v")
  end

  -- Cursor position is 1,0 indexed
  vim.api.nvim_win_set_cursor(0, { target_position.row + 1, target_position.col })
end

return M
