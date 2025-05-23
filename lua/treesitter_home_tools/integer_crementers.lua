local ts = vim.treesitter
local search = require("treesitter_home_tools.search")
local goto_node = require("treesitter_home_tools.goto_node").goto_node
local M = {}

---@param int_string string number string from integer Treesitter node
---@return number | nil, table<integer, string>
local function parse_integer_string(int_string)
  local parsed_int_text = ""
  local separator_table = {}
  local index = 1
  for c in int_string:reverse():gmatch(".") do
    if tonumber(c) then
      parsed_int_text = c .. parsed_int_text
    else
      separator_table[#separator_table + 1] = { index - #separator_table - 1, c }
    end
    index = index + 1
  end
  local parsed_int = tonumber(parsed_int_text)
  if parsed_int == nil then
    error("The parsed int string could not be type cast to number by lua?!")
  end
  return parsed_int, separator_table
end

---Increment string representing an integer, taking into account previously placed language specific delimiters
---@param int_string string
---@param inc number
---@return string
function M.increment_integer_string(int_string, inc)
  local parsed_int, separator_table = parse_integer_string(int_string)
  local new_number = parsed_int + inc
  local rev_new_number_string = tostring(new_number):reverse()
  if vim.tbl_isempty(separator_table) then
    return tostring(new_number)
  end
  return vim
    .iter(separator_table)
    :rev()
    :fold(rev_new_number_string, function(acc, k)
      local index, sep = unpack(k)
      return acc:sub(1, index) .. sep .. acc:sub(index + 1, #acc)
    end)
    :reverse()
end

---@param int_string string
---@param decrement number
---@return string
local function decrement_integer_string(int_string, decrement)
  local parsed_int, separator_table = parse_integer_string(int_string)
  local new_int = parsed_int - decrement
  if
    vim.tbl_isempty(separator_table)
    -- Since we only ever subtract possible nubmers,
    -- the only "crossover" of long numbers to roughly as long numbers
    -- are on the positive to negative edge
    or (parsed_int > 0 and new_int < 0)
  then
    return tostring(new_int)
  end

  local new_int_string = tostring(parsed_int - decrement):reverse()
  return vim
    .iter(separator_table)
    :rev()
    :filter(function(k)
      return k[1] < #new_int_string
    end)
    :fold(new_int_string, function(acc, k)
      local index, sep = unpack(k)
      return acc:sub(1, index) .. sep .. acc:sub(index + 1, #acc)
    end)
    :reverse()
end

---@param int_node TSNode
---@param decrement number
local function decrement_integer_node(int_node, decrement)
  local start_text = ts.get_node_text(int_node, 0)
  local start_row, start_col, end_row, end_col = int_node:range()
  vim.api.nvim_buf_set_text(
    0,
    start_row,
    start_col,
    end_row,
    end_col,
    { decrement_integer_string(start_text, decrement) }
  )
end

---@param int_node TSNode
---@param inc number
local function increment_integer_node(int_node, inc)
  local start_text = ts.get_node_text(int_node, 0)
  local start_row, start_col, end_row, end_col = int_node:range()
  vim.api.nvim_buf_set_text(
    0,
    start_row,
    start_col,
    end_row,
    end_col,
    { M.increment_integer_string(start_text, inc) }
  )
end

---@param parser vim.treesitter.LanguageTree
---@return TSNode?
local function find_next_integer_node(parser)
  local tree
  if not parser:is_valid() then
    tree = parser:parse()[1]
    if not parser:is_valid() then
      tree = parser:parse(true)[1]
    end
  else
    tree = parser:trees()[1]
  end
  local integer_query = ts.query.get(vim.bo.filetype, "integer_literal")
  if integer_query == nil then
    vim.notify("No integer literal query found for " .. vim.bo.filetype .. "!")
    return
  end
  local int_node = search.get_next_queried_node(tree, integer_query, { include_current = true })
  if int_node == nil then
    vim.notify("No integer literal node found ahead.")
    return
  end
  return int_node
end

---Increments next boolean despite language extra formatting choices, powered by Treesitter
---@param inc number Nice to get from vim.v.count1
function M.increment_next_integer(inc)
  local parser, _ = ts.get_parser()
  if parser == nil then
    vim.notify("No Treesitter parser could be found?", vim.diagnostic.severity.ERROR)
    return
  end
  local int_node = find_next_integer_node(parser)
  if int_node == nil then
    return
  end
  goto_node(int_node, false, true)
  increment_integer_node(int_node, inc)
  parser:parse()
  goto_node(int_node, true, false)
end

---Decrements next boolean despite language extra formatting choices, powered by Treesitter
---@param inc number Nice to get from vim.v.count1
function M.decrement_next_integer(inc)
  local parser, _ = ts.get_parser()
  if parser == nil then
    error("No Treesitter parser could be found?")
  end
  local int_node = find_next_integer_node(parser)
  if int_node == nil then
    return
  end
  goto_node(int_node, false, true)
  decrement_integer_node(int_node, inc)
  parser:parse()
  goto_node(int_node, true, false)
end

return M
