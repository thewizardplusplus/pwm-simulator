---
-- @classmod Color

local middleclass = require("middleclass")
local types = require("luaplot.types")

local Color = middleclass("Color")

---
-- @table instance
-- @tfield number red
-- @tfield number green
-- @tfield number blue
-- @tfield number alpha

---
-- @function new
-- @tparam number red [0, 1]
-- @tparam number green [0, 1]
-- @tparam number blue [0, 1]
-- @tparam number alpha [0, 1]
-- @treturn Color
function Color:initialize(red, green, blue, alpha)
  assert(types.is_number_with_limits(red, 0, 1))
  assert(types.is_number_with_limits(green, 0, 1))
  assert(types.is_number_with_limits(blue, 0, 1))
  assert(types.is_number_with_limits(alpha, 0, 1))

  self.red = red
  self.green = green
  self.blue = blue
  self.alpha = alpha
end

---
-- @treturn {number,number,number,number}
--   red, green, blue and alpha values in the range [0, 1]
function Color:channels()
  return {self.red, self.green, self.blue, self.alpha}
end

return Color
