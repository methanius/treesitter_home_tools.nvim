---@class ToggleBool
local M = {}

local toggle_bool_under_cursor = function()
  local word = vim.fn.expand("<cword>")
  if word == "true" then
    vim.cmd("normal! m`ciwfalse")
  elseif word == "false" then
    vim.cmd("normal! m`ciwtrue")
  elseif word == "True" then
    vim.cmd("normal! m`ciwFalse")
  elseif word == "False" then
    vim.cmd("normal! m`ciwTrue")
  end
end

--- Jumps to next boolean and switches its value. If no boolean is found, it does nothing
function M.toggle_next_bool()
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local filetype = vim.bo[vim.api.nvim_get_current_buf()].filetype
  local scope = vim.treesitter.get_node():tree():root()
  local ok, s_query = pcall(vim.treesitter.query.parse, filetype, "([(true) (false)]) @bools")
  if ok == true then
    for _, node, _ in
      s_query:iter_captures(scope, vim.api.nvim_get_current_buf(), cursor_line - 1, -1)
    do
      local node_end_line, node_end_col, _ = node:end_()
      if
        node_end_line + 1 > cursor_line
        or (node_end_line + 1 == cursor_line and node_end_col > cursor_col)
      then
        vim.api.nvim_win_set_cursor(0, { node_end_line + 1, node_end_col - 1 })
        toggle_bool_under_cursor()
        break
      end
    end
  end
end

--- Jumps to previous boolean and switches its value. If no boolean is found, it does nothing
function M.toggle_previous_bool()
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local filetype = vim.bo[vim.api.nvim_get_current_buf()].filetype
  local scope = vim.treesitter.get_node():tree():root()
  local ok, s_query = pcall(vim.treesitter.query.parse, filetype, "([(true) (false)]) @bools")
  if ok == true then
    local res_pos = nil
    for _, node, _ in s_query:iter_captures(scope, vim.api.nvim_get_current_buf(), 0, cursor_line) do
      local node_start_line, node_start_col, _ = node:start()
      local node_end_line, node_end_col, _ = node:end_()
      if
        node_start_line + 1 < cursor_line
        or (node_start_line + 1 == cursor_line and node_start_col < cursor_col)
      then
        res_pos = { node_end_line + 1, node_end_col - 1 }
      end
    end
    if res_pos ~= nil then
      vim.api.nvim_win_set_cursor(0, res_pos)
      toggle_bool_under_cursor()
    end
  end
end

return M
