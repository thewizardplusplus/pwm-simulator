---
-- @classmod StatsGroup

local middleclass = require("middleclass")
local Stats = require("models.stats")

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

  assert(Stats._is_parameter(parameter))
  assert(type(nullable) == "boolean")

  return math.max(
    self.current:percentage(parameter, nullable),
    self.best:percentage(parameter, nullable)
  )
end

---
-- @tparam[opt=false] bool nullable
function StatsGroup:update(nullable)
  nullable = nullable or false

  assert(type(nullable) == "boolean")

  local is_best_null = self.best:total(nullable) == 0
  local is_current_best = self.current:is_best(self.best, nullable)
  if is_best_null or is_current_best then
    self.best = self.current:copy()
  end
end

return StatsGroup
