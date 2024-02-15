---
-- @classmod Rectangle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

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
  assertions.is_integer(x)
  assertions.is_integer(y)
  assertions.is_integer(width)
  assertions.is_integer(height)

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
