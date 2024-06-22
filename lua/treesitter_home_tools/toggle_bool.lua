local ts = vim.treesitter
---@class TSNode
---
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

local _boolean_replacement_candidates = { t = "false", f = "true", T = "False", F = "True" }
---Toggles bool under cursor by going into insert mode
---@param node TSNode
local swap_bool_node_value = function(node)
  local replacement = _boolean_replacement_candidates[ts.get_node_text(
    node,
    vim.api.nvim_get_current_buf()
  )
    :sub(1, 1)]
  if replacement ~= nil then
    local start_row, start_col, end_row, end_col = node:range()
    vim.api.nvim_buf_set_text(
      vim.api.nvim_get_current_buf(),
      start_row,
      start_col,
      end_row,
      end_col,
      { replacement }
    )
  end
end

---Find the next node result from query input.
---If standing on a node result, get the last position of it
---@param opts NodeLocatorOpts
---@return TSNode?
---@package
local get_next_queried_node = function(opts)
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
          return node
        end
      else
        if end_row + 1 > cursor_line or (end_row + 1 == cursor_line and start_col > cursor_col) then
          return node
        end
      end
    end
  end
end

---Find the previous node result from query input.
---If standing on a node result, get the last position of it
---@param opts NodeLocatorOpts
---@return TSNode?
---@package
local get_previous_queried_node = function(opts)
  local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local filetype = vim.bo[vim.api.nvim_get_current_buf()].filetype
  local scope = vim.treesitter.get_node():tree():root()
  local ok, s_query = pcall(vim.treesitter.query.parse, filetype, opts.query)
  if ok == true then
    local ret_node = nil
    for _, node, _ in s_query:iter_captures(scope, vim.api.nvim_get_current_buf(), 0, cursor_line) do
      local start_row, start_col, _, end_col = node:range()
      if opts.include_current then
        if
          start_row + 1 < cursor_line
          or (start_row + 1 == cursor_line and start_col < cursor_col)
        then
          ret_node = node
        end
      else
        if
          start_row + 1 < cursor_line
          or (start_row + 1 == cursor_line and end_col < cursor_col)
        then
          ret_node = node
        end
      end
    end
    return ret_node
  end
end

---@type TreesitterQuery
local boolean_queries = {
  "([(true)(false)])@bools",
  "(boolean_scalar)@bools",
  "(boolean)@bools",
  "(boolean_literal)@bools",
  '((constructor)@bools (#any-of? @bools "True" "False"))',
}

--- Jumps to next boolean and switches its value. If no boolean is found, it does nothing
--- @param include_current_word? boolean
function M.toggle_next_bool(include_current_word)
  if include_current_word == nil then
    include_current_word = true
  end
  for _, boolean_query in pairs(boolean_queries) do
    local node = get_next_queried_node({
      query = boolean_query,
      include_current = include_current_word,
    })
    if node ~= nil then
      local node_end_row, node_end_col = node:end_()
      local old_text_len = ts.get_node_text(node, 0):len()
      vim.api.nvim_win_set_cursor(0, { node_end_row + 1, node_end_col - 1 })
      swap_bool_node_value(node)
      local new_v_old_text_diff = ts.get_node_text(node, 0):len() - old_text_len
      vim.api.nvim_win_set_cursor(0, { node_end_row + 1, node_end_col - 1 + new_v_old_text_diff })
      break
    end
  end
end

--- Jumps to previous boolean and switches its value. If no boolean is found, it does nothing
--- @param include_current_word? boolean
function M.toggle_previous_bool(include_current_word)
  if include_current_word == nil then
    include_current_word = true
  end
  for _, boolean_query in pairs(boolean_queries) do
    local node = get_previous_queried_node({
      query = boolean_query,
      include_current = include_current_word,
    })
    if node ~= nil then
      local node_end_row, node_end_col = node:end_()
      local old_text_len = ts.get_node_text(node, 0):len()
      vim.api.nvim_win_set_cursor(0, { node_end_row + 1, node_end_col - 1 })
      swap_bool_node_value(node)
      local new_v_old_text_diff = ts.get_node_text(node, 0):len() - old_text_len
      vim.api.nvim_win_set_cursor(0, { node_end_row + 1, node_end_col - 1 + new_v_old_text_diff })
      break
    end
  end
end

return M
