---
-- @classmod StatsGroup

local middleclass = require("middleclass")
local Stats = require("models.stats")

local StatsGroup = middleclass("StatsGroup")

---
-- @table instance
-- @tfield Stats current
-- @tfield Stats best

---
-- @function new
-- @treturn StatsGroup
function StatsGroup:initialize()
  self.current = Stats:new(0, 0, 0)
  self.best = Stats:new(0, 0, 0)
end

return StatsGroup
