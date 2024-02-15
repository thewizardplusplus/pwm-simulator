---
-- @classmod Point

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

local Point = middleclass("Point")

---
-- @table instance
-- @tfield number x
-- @tfield number y

---
-- @function new
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
-- @treturn Point
function Point:initialize(x, y)
  assertions.is_number(x)
  assertions.is_number(y)

  self.x = x
  self.y = y
end

return Point
