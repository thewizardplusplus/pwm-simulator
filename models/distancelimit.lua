---
-- @classmod DistanceLimit

local middleclass = require("middleclass")
local types = require("luaplot.types")

local DistanceLimit = middleclass("Point")

---
-- @table instance
-- @tfield number limit
-- @tfield any suitable_value

---
-- @function new
-- @tparam number limit
-- @tparam any suitable_value
-- @treturn DistanceLimit
function DistanceLimit:initialize(limit, suitable_value)
  assert(types.is_number_with_limits(limit, 0))

  self.limit = limit
  self.suitable_value = suitable_value
end

return DistanceLimit
