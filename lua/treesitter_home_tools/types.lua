---@alias TreesitterQuery string

---@class LanguageQueries
---@field bool_query TreesitterQuery?
---@field integer_query TreesitterQuery?

---@class SearchOpts
---@field query TreesitterQuery
---@field include_current boolean

---@class (exact) TreesitterHomeTools.Config
---@field enable_toggle_boolean boolean
---@field enable_increment boolean
---@field create_usercommands boolean
