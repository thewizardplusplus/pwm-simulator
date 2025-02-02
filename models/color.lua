-- luacheck: no max comment line length

---
-- @classmod Color

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

local Color = middleclass("Color")
Color:include(Nameable)
Color:include(Stringifiable)

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
  assertions.is_number(red)
  assertions.is_number(green)
  assertions.is_number(blue)
  assertions.is_number(alpha)

  self.red = red
  self.green = green
  self.blue = blue
  self.alpha = alpha
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function Color:__data()
  return {
    red = self.red,
    green = self.green,
    blue = self.blue,
    alpha = self.alpha,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

---
-- @treturn {number,number,number,number}
--   red, green, blue and alpha values in the range [0, 1]
function Color:channels()
  return {self.red, self.green, self.blue, self.alpha}
end

return Color
