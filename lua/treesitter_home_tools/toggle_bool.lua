local ts = vim.treesitter
local search = require("treesitter_home_tools.search")
local goto_node = require("treesitter_home_tools.goto_node").goto_node

local M = {}

local _boolean_replacement_candidates = { t = "false", f = "true", T = "False", F = "True" }
---Toggles bool under cursor by going into insert mode
---@param node TSNode
local function swap_boolean_literal_node_value(node)
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

---@param search_type "next" | "prev" Which direction to search in
local function toggle_searched_boolean_literal(search_type)
  local parser = ts.get_parser()
  if parser == nil then
    return
  end

  ---@type TSTree
  local tree
  if not parser:is_valid() then
    tree = parser:parse()[1]
  else
    tree = parser:trees()[1]
  end
  local lang = vim.bo.filetype
  local boolean_literal_query = ts.query.get(lang, "boolean_literal")
  if boolean_literal_query == nil then
    vim.notify("No boolean query found for " .. lang .. "!")
    return
  end
  ---@type TSNode?
  local node
  if search_type == "next" then
    node = search.get_next_queried_node(tree, boolean_literal_query)
    if node == nil then
      vim.notify("No boolean node found ahead.")
      return
    end
  elseif search_type == "prev" then
    node = search.get_previous_queried_node(tree, boolean_literal_query)
    if node == nil then
      vim.notify("No previous boolean found.")
      return
    end
  end
  if node == nil then
    vim.notify(
      "All possible node states should have been handled here?!",
      vim.diagnostic.severity.ERROR
    )
    return
  end
  goto_node(node, false, true)
  swap_boolean_literal_node_value(node)
  --Reparse for goto_node to work on updated node
  parser:parse()
  local new_node = ts.get_node()
  if new_node == nil then
    vim.notify("No new node after bool toggle!?")
    return
  end
  goto_node(new_node, true, false)
end

--- Jumps to next boolean and switches its value. If no boolean is found, it does nothing
function M.toggle_next_bool()
  toggle_searched_boolean_literal("next")
end

--- Jumps to previous boolean and switches its value. If no boolean is found, it does nothing
function M.toggle_previous_bool()
  toggle_searched_boolean_literal("prev")
end

return M
