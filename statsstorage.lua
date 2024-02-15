---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local flatdb = require("flatdb")
local assertions = require("luatypechecks.assertions")
local Stats = require("models.stats")

local StatsStorage = middleclass("StatsStorage")

---
-- @table instance
-- @tfield FlatDB _db

---
-- @function new
-- @tparam string path
-- @treturn StatsStorage
function StatsStorage:initialize(path)
  assertions.is_string(path)

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
  assertions.is_instance(stats, Stats)

  self._db.stats = {
    normal_time = stats.normal_time,
    soft_limit_time = stats.soft_limit_time,
    hard_limit_time = stats.hard_limit_time,
  }

  self._db:save()
end

return StatsStorage
