---
-- @module factory

local StatsStorage = require("statsstorage")

local factory = {}

---
-- @tparam string path
-- @treturn StatsStorage
-- @error error message
function factory.create_stats_storage(path)
  assert(type(path) == "string")

  local ok = love.filesystem.createDirectory(path)
  if not ok then
    return nil, "unable to create the stats DB"
  end

  local full_path = love.filesystem.getSaveDirectory() .. "/" .. path
  return StatsStorage:new(full_path)
end

return factory
