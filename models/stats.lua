---
-- @classmod Stats

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")

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
  return checks.is_enumeration(
    parameter,
    {"normal", "soft_limit", "hard_limit"}
  )
end

---
-- @function new
-- @tparam number normal_time [0, ∞)
-- @tparam number soft_limit_time [0, ∞)
-- @tparam number hard_limit_time [0, ∞)
-- @treturn Stats
function Stats:initialize(normal_time, soft_limit_time, hard_limit_time)
  assertions.is_number(normal_time)
  assertions.is_number(soft_limit_time)
  assertions.is_number(hard_limit_time)

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

  assertions.is_instance(sample, Stats)
  assertions.is_boolean(nullable)

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

  assertions.is_boolean(nullable)

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

  assertions.is_true(Stats.is_parameter(parameter))
  assertions.is_boolean(nullable)

  return self[parameter .. "_time"] / self:total(nullable) * 100
end

---
-- @tparam "normal"|"soft_limit"|"hard_limit" parameter
-- @tparam number delta [0, ∞)
function Stats:increase(parameter, delta)
  assertions.is_true(Stats.is_parameter(parameter))
  assertions.is_number(delta)

  parameter = parameter .. "_time"
  self[parameter] = self[parameter] + delta
end

return Stats
