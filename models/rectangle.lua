---
-- @classmod Rectangle

local middleclass = require("middleclass")
local types = require("luaplot.types")

---
-- @table instance
-- @tfield number x [0, ∞)
-- @tfield number y [0, ∞)
-- @tfield number width [0, ∞)
-- @tfield number height [0, ∞)

local Rectangle = middleclass("Rectangle")

---
-- @function new
-- @tparam number x [0, ∞)
-- @tparam number y [0, ∞)
-- @tparam number width [0, ∞)
-- @tparam number height [0, ∞)
-- @treturn Rectangle
function Rectangle:initialize(x, y, width, height)
  assert(types.is_number_with_limits(x, 0))
  assert(types.is_number_with_limits(y, 0))
  assert(types.is_number_with_limits(width, 0))
  assert(types.is_number_with_limits(height, 0))

  self.x = x
  self.y = y
  self.width = width
  self.height = height
end

---
-- @tparam int plot_height
-- @treturn int
function Rectangle:vertical_offset(plot_height)
  assert(types.is_number_with_limits(plot_height, 0))

  return self.y + (self.height - plot_height) / 2
end

return Rectangle
