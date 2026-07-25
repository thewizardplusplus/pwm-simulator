-- luacheck: no max comment line length

---
-- @classmod Stats

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

local Stats = middleclass("Stats")
Stats:include(Nameable)
Stats:include(Stringifiable)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Stats.static.schema()
  local positive_number = { type = "number", minimum = 0 }

  return {
    type = "object",
    required = {"normal_time", "soft_limit_time", "hard_limit_time"},
    properties = {
      normal_time = positive_number,
      soft_limit_time = positive_number,
      hard_limit_time = positive_number,
    },
  }
end

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{Stats.schema|Stats.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn Stats
function Stats.static.from_options(options)
  assertions.is_table(options)

  return Stats:new(
    options.normal_time,
    options.soft_limit_time,
    options.hard_limit_time
  )
end

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
  return checks.is_enumeration(parameter, {
    "normal",
    "soft_limit",
    "hard_limit",
  })
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
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Stats:__data()
  return {
    normal_time = self.normal_time,
    soft_limit_time = self.soft_limit_time,
    hard_limit_time = self.hard_limit_time,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

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
