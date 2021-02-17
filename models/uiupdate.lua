---
-- @classmod UiUpdate

local middleclass = require("middleclass")

---
-- @table instance
-- @tfield bool pause

local UiUpdate = middleclass("UiUpdate")

---
-- @function new
-- @tparam bool pause
-- @treturn UiUpdate
function UiUpdate:initialize(pause)
  assert(type(pause) == "boolean")

  self.pause = pause
end

return UiUpdate
