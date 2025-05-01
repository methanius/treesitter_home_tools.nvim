local M = {}

---@type TreesitterHomeTools.Config
local defaults = {
  enable_toggle_boolean = true,
  create_usercommands = true,
  enable_increment = true,
}

M.options = defaults

---@param opts? TreesitterHomeTools.Config
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  if M.options.enable_toggle_boolean then
    local toggle_bool = require("treesitter_home_tools.toggle_bool")
    M.toggle_next_bool = toggle_bool.toggle_next_bool
    M.toggle_previous_bool = toggle_bool.toggle_previous_bool
    if M.options.create_usercommands then
      vim.api.nvim_create_user_command(
        "ToggleNextBool",
        require("treesitter_home_tools").toggle_next_bool,
        { bar = true, desc = "Toggles next boolean using Treesitter" }
      )
      vim.api.nvim_create_user_command(
        "TogglePreviousBool",
        require("treesitter_home_tools").toggle_previous_bool,
        { bar = true, desc = "Toggles previous boolean using Treesitter" }
      )
    end
  end
  if M.options.enable_increment then
    local crementer = require("treesitter_home_tools.crementer")
    M.increment_next_integer = crementer.increment_next_integer
  end
end

return M
