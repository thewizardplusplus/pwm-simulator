---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local flatdb = require("flatdb")
local types = require("luaplot.types")
local Stats = require("models.stats")

local StatsStorage = middleclass("StatsStorage")

---
-- @table instance
-- @tfield FlatDB _db

---
-- @function create
-- @static
-- @tparam string path
-- @treturn StatsStorage
-- @error error message
function StatsStorage.static.create(path)
  assert(type(path) == "string")

  local ok = love.filesystem.createDirectory(path)
  if not ok then
    return nil, "unable to create the stats DB"
  end

  local full_path = love.filesystem.getSaveDirectory() .. "/" .. path
  return StatsStorage:new(full_path)
end

---
-- @function new
-- @tparam string path
-- @treturn StatsStorage
function StatsStorage:initialize(path)
  assert(type(path) == "string")

  self._db = flatdb(path)
  if not self._db.stats then
    self._db.stats = {
      normal_time = 0,
      soft_limit_time = 0,
      hard_limit_time = 0,
    }
  end
end

---
-- @treturn Stats
function StatsStorage:get_stats()
  return Stats:new(
    self._db.stats.normal_time,
    self._db.stats.soft_limit_time,
    self._db.stats.hard_limit_time
  )
end

---
-- @tparam Stats stats
function StatsStorage:store_stats(stats)
  assert(types.is_instance(stats, Stats))

  self._db.stats = {
    normal_time = stats.normal_time,
    soft_limit_time = stats.soft_limit_time,
    hard_limit_time = stats.hard_limit_time,
  }

  self._db:save()
end

return StatsStorage
