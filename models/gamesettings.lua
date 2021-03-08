---
-- @classmod GameSettings

local middleclass = require("middleclass")
local types = require("luaplot.types")

local GameSettings = middleclass("GameSettings")

---
-- @table instance
-- @tfield int plot_sampling_rate
-- @tfield int distance_sampling_rate

---
-- @function new
-- @tparam int plot_sampling_rate
-- @tparam int distance_sampling_rate
-- @treturn GameSettings
function GameSettings:initialize(
  plot_sampling_rate,
  distance_sampling_rate
)
  assert(types.is_number_with_limits(plot_sampling_rate, 0))
  assert(types.is_number_with_limits(distance_sampling_rate, 0))

  self.plot_sampling_rate = plot_sampling_rate
  self.distance_sampling_rate = distance_sampling_rate
end

return GameSettings
