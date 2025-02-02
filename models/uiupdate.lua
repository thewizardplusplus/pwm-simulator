-- luacheck: no max comment line length

---
-- @classmod UiUpdate

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")

local UiUpdate = middleclass("UiUpdate")
UiUpdate:include(Nameable)
UiUpdate:include(Stringifiable)

---
-- @table instance
-- @tfield bool pause

---
-- @function new
-- @tparam bool pause
-- @treturn UiUpdate
function UiUpdate:initialize(pause)
  assertions.is_boolean(pause)

  self.pause = pause
end

---
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function UiUpdate:__data()
  return {
    pause = self.pause,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

return UiUpdate
