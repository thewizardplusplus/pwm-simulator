---
-- @classmod Point

local middleclass = require("middleclass")
local types = require("luaplot.types")

local Point = middleclass("Point")

---
-- @table instance
-- @tfield number x
-- @tfield number y

---
-- @function new
-- @tparam number x
-- @tparam number y
-- @treturn Point
function Point:initialize(x, y)
  assert(types.is_number_with_limits(x, 0))
  assert(types.is_number_with_limits(y, 0))

  self.x = x
  self.y = y
end

return Point
