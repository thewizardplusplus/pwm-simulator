---
-- @classmod GameSettings

local middleclass = require("middleclass")
local types = require("luaplot.types")
local Rectangle = require("models.rectangle")

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

---
-- @tparam "random"|"custom" plot
-- @treturn number
function GameSettings:plot_length(plot)
  assert(plot == "random" or plot == "custom")

  local factor
  if plot == "random" then
    factor = 0.75
  elseif plot == "custom" then
    factor = 0.5
  end

  return factor * self.plot_sampling_rate + 1
end

---
-- @tparam Rectangle screen
-- @tparam "plot"|"distance" parameter
-- @treturn number
function GameSettings:step(screen, parameter)
  assert(types.is_instance(screen, Rectangle))
  assert(parameter == "plot" or parameter == "distance")

  local width = screen.width
  if parameter == "distance" then
    width = width / 2
  end

  return width / self[parameter .. "_sampling_rate"]
end

return GameSettings
