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
-- @function new
-- @tparam number normal_time
-- @tparam number soft_limit_time
-- @tparam number hard_limit_time
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
-- @tparam "normal"|"soft_limit"|"hard_limit" parameter
-- @tparam[opt=false] bool nullable
-- @treturn number [0, 100]
function Stats:percentage(parameter, nullable)
  nullable = nullable or false

  assert(
    parameter == "normal"
    or parameter == "soft_limit"
    or parameter == "hard_limit"
  )
  assert(type(nullable) == "boolean")

  return self[parameter .. "_time"] / self:total(nullable) * 100
end

return Stats
