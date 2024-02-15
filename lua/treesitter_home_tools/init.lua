---@class (exact) TreesitterHomeTools.Commands
---@field options TreesitterHomeTools.Config
---@field toggle_next_bool fun(boolean?)?
---@field toggle_previous_bool fun(boolean?)?
---@field setup function
---@field dot_repeater? fun(fun): fun()
local M = {}

---@class (exact) TreesitterHomeTools.Config
---@field enable_toggle_boolean boolean
local defaults = {
  enable_toggle_boolean = true,
}

M.options = defaults

---@param opts? TreesitterHomeTools.Config
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  if M.options.enable_toggle_boolean then
    local toggle_bool = require("treesitter_home_tools.toggle_bool")
    vim.api.nvim_create_user_command("ToggleNextBool", function()
      toggle_bool.toggle_next_bool()
    end, { bar = true, bang = true, nargs = "?", desc = "Toggles next boolean using Treesitter" })
    M.toggle_next_bool = toggle_bool.toggle_next_bool
    M.toggle_previous_bool = toggle_bool.toggle_previous_bool
  end
end

return M
