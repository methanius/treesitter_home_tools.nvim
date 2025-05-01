local ts = vim.treesitter
local lang_queries = require("treesitter_home_tools.langs_queries")
local search = require("treesitter_home_tools.search")

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

--- Jumps to next boolean and switches its value. If no boolean is found, it does nothing
--- @param include_current_word? boolean
function M.toggle_next_bool(include_current_word)
  if include_current_word == nil then
    include_current_word = true
  end
  local parser = ts.get_parser()
  if parser == nil then
    return
  end
  local tree = parser:parse()[1]
  local node = search.get_next_queried_node(tree, {
    query = lang_queries[vim.bo.filetype].bool_query,
    include_current = include_current_word,
  })
  if node ~= nil then
    swap_bool_node_value(node)
    local initial_bool_text = ts.get_node_text(node, 0)
    local og_end_row, og_end_col, _ = node:end_()
    local end_adjust = initial_bool_text:len() == 4 and 1 or -1
    vim.api.nvim_win_set_cursor(0, { og_end_row + 1, og_end_col - 1 + end_adjust })
  else
    vim.notify("No boolean found!")
  end
end

--- Jumps to previous boolean and switches its value. If no boolean is found, it does nothing
--- @param include_current_word? boolean
function M.toggle_previous_bool(include_current_word)
  if include_current_word == nil then
    include_current_word = true
  end
  local parser = ts.get_parser()
  if parser == nil then
    return
  end
  local tree = parser:parse()[1]
  local node = search.get_previous_queried_node(tree, {
    query = lang_queries[vim.bo.filetype].bool_query,
    include_current = include_current_word,
  })
  if node ~= nil then
    swap_bool_node_value(node)
    local initial_bool_text = ts.get_node_text(node, 0)
    local og_end_row, og_end_col, _ = node:end_()
    local end_adjust = initial_bool_text:len() == 4 and 1 or -1
    vim.api.nvim_win_set_cursor(0, { og_end_row + 1, og_end_col - 1 + end_adjust })
  else
    vim.notify("No boolean found!")
  end
end

return M
