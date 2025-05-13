local int_crem = require("treesitter_home_tools.integer_crementers")
local M = {}

---@param float_string string Float text from float TSNode
---@param inc number Increment
---@return string
function M.increment_integer_part_of_float_string(float_string, inc)
  local dot_index = float_string:find("%.")
  if dot_index == nil then
    return int_crem.increment_integer_string(float_string, inc)
  end
  return int_crem.increment_integer_string(float_string:sub(1, dot_index), inc)
    .. float_string:sub(dot_index + 1, #float_string)
end

return M
