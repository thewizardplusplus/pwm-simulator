---
-- @classmod StatsStorage

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local json = require("luaserialization.json")
local Stats = require("models.stats")

local StatsStorage = middleclass("StatsStorage")

---
-- @table instance
-- @tfield string _path
-- @tfield Stats _stats

---
-- @function new
-- @tparam string path
-- @treturn StatsStorage
function StatsStorage:initialize(path)
  assertions.is_string(path)

  local stats, err = json.load_from_json(
    path,
    Stats.schema(),
    { Stats = Stats.from_options },
    function(path) -- luacheck: no redefined
      assertions.is_string(path)

      local data, err = love.filesystem.read(path)
      return data, data == nil and err or nil
    end
  )
  if not stats then
    print("unable to load the stats: " .. err)

    stats = Stats:new(0, 0, 0)
  end

  self._path = path
  self._stats = stats
end

---
-- @treturn Stats
function StatsStorage:stats()
  return self._stats
end

---
-- @tparam Stats stats
function StatsStorage:store_stats(stats)
  assertions.is_instance(stats, Stats)

  self._stats = stats

  local ok, err = json.save_to_json(self._path, stats, love.filesystem.write)
  if not ok then
    print("unable to save the stats: " .. err)
  end
end

return StatsStorage
