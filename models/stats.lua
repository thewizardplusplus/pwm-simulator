---
-- @classmod Stats

local middleclass = require("middleclass")
local types = require("luaplot.types")

local Stats = middleclass("Stats")

---
-- @table instance
-- @tfield number normal_time
-- @tfield number soft_limit_time
-- @tfield number hard_limit_time

---
-- @function is_parameter
-- @static
-- @tparam any parameter
-- @treturn bool
function Stats.static.is_parameter(parameter)
  return table.find({"normal", "soft_limit", "hard_limit"}, parameter)
end

---
-- @function new
-- @tparam number normal_time [0, ∞)
-- @tparam number soft_limit_time [0, ∞)
-- @tparam number hard_limit_time [0, ∞)
-- @treturn Stats
function Stats:initialize(normal_time, soft_limit_time, hard_limit_time)
  assert(types.is_number_with_limits(normal_time, 0))
  assert(types.is_number_with_limits(soft_limit_time, 0))
  assert(types.is_number_with_limits(hard_limit_time, 0))

  self.normal_time = normal_time
  self.soft_limit_time = soft_limit_time
  self.hard_limit_time = hard_limit_time
end

---
-- @tparam Stats sample
-- @tparam[opt=false] bool nullable
-- @treturn bool
function Stats:is_best(sample, nullable)
  nullable = nullable or false

  assert(types.is_instance(sample, Stats))
  assert(type(nullable) == "boolean")

  local self_normal_percentage = self:percentage("normal", nullable)
  local self_soft_limit_percentage = self:percentage("soft_limit", nullable)

  local sample_normal_percentage = sample:percentage("normal", nullable)
  local sample_soft_limit_percentage = sample:percentage("soft_limit", nullable)

  return self_normal_percentage > sample_normal_percentage
    or (self_normal_percentage == sample_normal_percentage
    and self_soft_limit_percentage > sample_soft_limit_percentage)
end

---
-- @tparam[opt=false] bool nullable
-- @treturn number
function Stats:total(nullable)
  nullable = nullable or false

  assert(type(nullable) == "boolean")

  local total = self.normal_time + self.soft_limit_time + self.hard_limit_time
  -- for preventing division by zero
  if not nullable and total == 0 then
    total = 1
  end

  return total
end

---
-- @treturn Stats
function Stats:copy()
  return Stats:new(self.normal_time, self.soft_limit_time, self.hard_limit_time)
end

---
-- @tparam "normal"|"soft_limit"|"hard_limit" parameter
-- @tparam[opt=false] bool nullable
-- @treturn number [0, 100]
function Stats:percentage(parameter, nullable)
  nullable = nullable or false

  assert(Stats.is_parameter(parameter))
  assert(type(nullable) == "boolean")

  return self[parameter .. "_time"] / self:total(nullable) * 100
end

---
-- @tparam "normal"|"soft_limit"|"hard_limit" parameter
-- @tparam number delta [0, ∞)
function Stats:increase(parameter, delta)
  assert(Stats.is_parameter(parameter))
  assert(types.is_number_with_limits(delta, 0))

  parameter = parameter .. "_time"
  self[parameter] = self[parameter] + delta
end

return Stats
