-- luacheck: no max comment line length

---
-- @classmod Rectangle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

local Rectangle = middleclass("Rectangle")
Rectangle:include(Nameable)
Rectangle:include(Stringifiable)

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
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Rectangle:__data()
  return {
    x = self.x,
    y = self.y,
    width = self.width,
    height = self.height,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

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
