local ts = vim.treesitter
local langs_queries = require("treesitter_home_tools.langs_queries")
local search = require("treesitter_home_tools.search")
local M = {}

---@param int_string string Integer string from integer Treesitter node
---@return integer | nil, table<integer, string> |nil
local parse_integer_string = function(int_string)
  local parsed_int_text = ""
  local separator_table = {}
  local index = 1
  for c in int_string:gmatch(".") do
    if tonumber(c) then
      parsed_int_text = parsed_int_text .. c
    else
      separator_table[index] = c
    end
    index = index + 1
  end
  local parsed_int = tonumber(parsed_int_text)
  if parsed_int == nil then
    return
  end
  return parsed_int, separator_table
end

---@param int_node TSNode
---@param inc integer
local increment_integer_node = function(int_node, inc)
  local parsed_int, separator_table =
    parse_integer_string(ts.get_node_text(int_node, vim.api.nvim_get_current_buf()))
  if parsed_int == nil then
    vim.notify("Couldn't parse integer node text to int?!")
  end
  local new_number_string = tostring(parsed_int + inc)
  local result_integer_text = ""
  if separator_table == nil or vim.tbl_isempty(separator_table) then
    result_integer_text = result_integer_text .. new_number_string
  else
    local inserted = 0
    local previous_index = 1
    for sep_index, separator in pairs(separator_table) do
      result_integer_text = result_integer_text
        .. new_number_string:sub(previous_index - inserted, sep_index - inserted - 1)
        .. separator
      inserted = inserted + 1
      previous_index = sep_index + 1
    end
    result_integer_text = result_integer_text
      .. new_number_string:sub(previous_index - inserted, #new_number_string)
  end
  local start_row, start_col, end_row, end_col = int_node:range()
  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { result_integer_text })
end

---Increments next boolean despite language extra formatting choices, powered by Treesitter
---@param inc number Nice to get from vim.v.count1
function M.increment_next_integer(inc)
  local parser = ts.get_parser()
  if parser == nil then
    return
  end
  local tree = parser:parse(true)[1]
  if not parser:is_valid() then
    vim.notify("Parser currently invalid!")
    return
  end
  local int_node = search.get_next_queried_node(
    tree,
    { query = langs_queries[vim.bo.filetype].integer_query, include_current = true }
  )
  if int_node == nil then
    vim.notify("No integer node found ahead.")
    return
  end
  increment_integer_node(int_node, inc)
  local start_row, start_col, _ = int_node:start()
  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col - 1 })
  vim.api.nvim_feedkeys("e", "n", true)
end

return M
