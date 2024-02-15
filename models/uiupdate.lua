---
-- @classmod UiUpdate

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")

local UiUpdate = middleclass("UiUpdate")

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

return UiUpdate
