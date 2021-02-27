---
-- @classmod PlotGroup

local middleclass = require("middleclass")
local types = require("luaplot.types")
local Oscillogram = require("luaplot.oscillogram")

local PlotGroup = middleclass("PlotGroup")

---
-- @table instance
-- @tfield Oscillogram random
-- @tfield Oscillogram custom
-- @tfield Oscillogram custom_source

---
-- @function new
-- @tparam int step_count
-- @treturn PlotGroup
function PlotGroup:initialize(step_count)
  assert(types.is_number_with_limits(step_count, 0))

  self.random = Oscillogram:new("random", 0.75 * step_count + 1, 0.5)
  self.custom = Oscillogram:new("linear", step_count / 2 + 1, 0.5)
  self.custom_source = Oscillogram:new("custom", step_count / 2 + 1, 0.5)
end

return PlotGroup
