---
-- @classmod Rectangle

local middleclass = require("middleclass")
local types = require("luaplot.types")

local Rectangle = middleclass("Rectangle")

---
-- @table instance
-- @tfield int x
-- @tfield int y
-- @tfield int width
-- @tfield int height

---
-- @function new
-- @tparam int x [0, ∞)
-- @tparam int y [0, ∞)
-- @tparam int width [0, ∞)
-- @tparam int height [0, ∞)
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
-- @treturn number
function Rectangle:plot_height()
  return self.height / 1.5
end

---
-- @treturn number
function Rectangle:vertical_offset()
  return self.y + (self.height - self:plot_height()) / 2
end

return Rectangle
