---
-- @classmod StatsGroup

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local iterators = require("luaplot.iterators")
local DistanceLimit = require("luaplot.distancelimit")
local Stats = require("models.stats")
local GameSettings = require("models.gamesettings")
local PlotGroup = require("models.plotgroup")

local StatsGroup = middleclass("StatsGroup")

---
-- @table instance
-- @tfield Stats current
-- @tfield Stats best

---
-- @function new
-- @treturn StatsGroup
function StatsGroup:initialize()
  self.current = Stats:new(0, 0, 0)
  self.best = Stats:new(0, 0, 0)
end

---
-- @tparam "normal"|"soft_limit"|"hard_limit" parameter
-- @tparam[opt=false] bool nullable
-- @treturn number [0, 100]
function StatsGroup:max_percentage(parameter, nullable)
  nullable = nullable or false

  assertions.is_true(Stats.is_parameter(parameter))
  assertions.is_boolean(nullable)

  return math.max(
    self.current:percentage(parameter, nullable),
    self.best:percentage(parameter, nullable)
  )
end

---
-- @tparam GameSettings settings
-- @tparam PlotGroup plots
-- @tparam number delta [0, ∞)
function StatsGroup:increase_current(settings, plots, delta)
  assertions.is_instance(settings, GameSettings)
  assertions.is_instance(plots, PlotGroup)
  assertions.is_number(delta)

  local index = math.floor(settings:plot_length("custom"))
  local suitable_parameter =
    iterators.select_by_distance(plots.random, plots.custom, index, true, {
      DistanceLimit:new(settings.soft_distance_limit, "normal"),
      DistanceLimit:new(settings.hard_distance_limit, "soft_limit"),
      DistanceLimit:new(math.huge, "hard_limit"),
    })
  self.current:increase(suitable_parameter, delta)
end

---
-- @tparam[opt=false] bool nullable
function StatsGroup:update_best(nullable)
  nullable = nullable or false

  assertions.is_boolean(nullable)

  local is_best_null = self.best:total(nullable) == 0
  local is_current_best = self.current:is_best(self.best, nullable)
  if is_best_null or is_current_best then
    self.best = self.current:copy()
  end
end

return StatsGroup
