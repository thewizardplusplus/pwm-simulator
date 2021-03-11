---
-- @classmod UiUpdate

local middleclass = require("middleclass")

local UiUpdate = middleclass("UiUpdate")

---
-- @table instance
-- @tfield bool pause

---
-- @function new
-- @tparam bool pause
-- @treturn UiUpdate
function UiUpdate:initialize(pause)
  assert(type(pause) == "boolean")

  self.pause = pause
end

return UiUpdate
