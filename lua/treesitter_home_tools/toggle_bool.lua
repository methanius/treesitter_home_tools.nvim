---@class NodePosition
---@field row integer
---@field col integer

---@alias TreesitterQuery string
---
---@class NodeLocatorOpts
---@field query TreesitterQuery
---@field include_current boolean

---@class ToggleBool
---@field toggle_next_bool? fun(boolean)
---@field repeatable_toggle_next_bool? fun(boolean)
---@field toggle_previous_bool? fun(boolean)
---@field _repeated boolean

---@type ToggleBool
local M = {}

---Toggles bool under cursor by going into insert mode
local swap_bool_under_cursor = function()
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

---Find the next node result from query input.
---If standing on a node result, get the last position of it
---@param opts NodeLocatorOpts
---@return NodePosition?
---@package
local get_next_queried_node_position = function(opts)
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local filetype = vim.bo[vim.api.nvim_get_current_buf()].filetype
  local scope = vim.treesitter.get_node():tree():root()
  local ok, s_query = pcall(vim.treesitter.query.parse, filetype, opts.query)
  if ok == true then
    for _, node, _ in
      s_query:iter_captures(scope, vim.api.nvim_get_current_buf(), cursor_line - 1, -1)
    do
      local _, start_col, end_row, end_col = node:range()
      if opts.include_current then
        if end_row + 1 > cursor_line or (end_row + 1 == cursor_line and end_col > cursor_col) then
          return { end_row + 1, end_col - 1 }
        end
      else
        if end_row + 1 > cursor_line or (end_row + 1 == cursor_line and start_col > cursor_col) then
          return { end_row + 1, end_col - 1 }
        end
      end
    end
  end
end

---Find the previous node result from query input.
---If standing on a node result, get the last position of it
---@param opts NodeLocatorOpts
---@return NodePosition?
---@package
local get_previous_queried_node_position = function(opts)
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local filetype = vim.bo[vim.api.nvim_get_current_buf()].filetype
  local scope = vim.treesitter.get_node():tree():root()
  local ok, s_query = pcall(vim.treesitter.query.parse, filetype, opts.query)
  if ok == true then
    local res_pos = nil
    for _, node, _ in s_query:iter_captures(scope, vim.api.nvim_get_current_buf(), 0, cursor_line) do
      local start_row, start_col, end_row, end_col = node:range()
      if opts.include_current then
        if
          start_row + 1 < cursor_line
          or (start_row + 1 == cursor_line and start_col < cursor_col)
        then
          res_pos = { end_row + 1, end_col - 1 }
        end
      else
        if
          start_row + 1 < cursor_line
          or (start_row + 1 == cursor_line and end_col < cursor_col )
        then
          res_pos = { end_row + 1, end_col - 1 }
        end
      end
    end
    return res_pos
  end
end

---@type TreesitterQuery
local boolean_query = "([(true) (false)])@bools"

--- Jumps to next boolean and switches its value. If no boolean is found, it does nothing
--- @param include_current_word? boolean
function M.toggle_next_bool(include_current_word)
  if include_current_word == nil then
    include_current_word = true
  end
  local pos = get_next_queried_node_position({
    query = boolean_query,
    include_current = include_current_word,
  })
  if pos ~= nil then
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] })
    swap_bool_under_cursor()
  end
end

--- Jumps to previous boolean and switches its value. If no boolean is found, it does nothing
--- @param include_current_word? boolean
function M.toggle_previous_bool(include_current_word)
  if include_current_word == nil then
    include_current_word = true
  end
  local res_pos = get_previous_queried_node_position({
    query = boolean_query,
    include_current = include_current_word,
  })
  if res_pos ~= nil then
    vim.api.nvim_win_set_cursor(0, res_pos)
    swap_bool_under_cursor()
  end
end

return M
