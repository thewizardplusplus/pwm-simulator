---
-- @classmod GameSettings

local middleclass = require("middleclass")
local types = require("luaplot.types")
local Rectangle = require("models.rectangle")

local GameSettings = middleclass("GameSettings")

---
-- @table instance
-- @tfield number plot_sampling_speed
-- @tfield int plot_sampling_rate
-- @tfield int distance_sampling_rate
-- @tfield number soft_distance_limit
-- @tfield number hard_distance_limit
-- @tfield number random_plot_factor
-- @tfield number inactive_custom_plot_factor
-- @tfield number active_custom_plot_factor

---
-- @function new
-- @tparam number plot_sampling_speed [0, ∞)
-- @tparam int plot_sampling_rate [0, ∞)
-- @tparam int distance_sampling_rate [0, ∞)
-- @tparam number soft_distance_limit [0, 1]
-- @tparam number hard_distance_limit [soft\_distance\_limit, 1]
-- @tparam number random_plot_factor [0, ∞)
-- @tparam number inactive_custom_plot_factor
-- @tparam number active_custom_plot_factor
-- @treturn GameSettings
function GameSettings:initialize(
  plot_sampling_speed,
  plot_sampling_rate,
  distance_sampling_rate,
  soft_distance_limit,
  hard_distance_limit,
  random_plot_factor,
  inactive_custom_plot_factor,
  active_custom_plot_factor
)
  assert(types.is_number_with_limits(plot_sampling_speed, 0))
  assert(types.is_number_with_limits(plot_sampling_rate, 0))
  assert(types.is_number_with_limits(distance_sampling_rate, 0))
  assert(types.is_number_with_limits(soft_distance_limit, 0, 1))
  assert(types.is_number_with_limits(
    hard_distance_limit,
    soft_distance_limit,
    1
  ))
  assert(types.is_number_with_limits(random_plot_factor, 0))
  assert(types.is_number_with_limits(inactive_custom_plot_factor))
  assert(types.is_number_with_limits(active_custom_plot_factor))

  self.plot_sampling_speed = plot_sampling_speed
  self.plot_sampling_rate = plot_sampling_rate
  self.distance_sampling_rate = distance_sampling_rate
  self.soft_distance_limit = soft_distance_limit
  self.hard_distance_limit = hard_distance_limit
  self.random_plot_factor = random_plot_factor
  self.inactive_custom_plot_factor = inactive_custom_plot_factor
  self.active_custom_plot_factor = active_custom_plot_factor
end

---
-- @treturn number
function GameSettings:update_delay()
  return 1 / (self.plot_sampling_speed * self.plot_sampling_rate)
end

---
-- @tparam "random"|"custom" plot
-- @treturn number
function GameSettings:plot_length(plot)
  assert(table.find({"random", "custom"}, plot))

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
  assert(table.find({"plot", "distance"}, parameter))

  local width = screen.width
  if parameter == "distance" then
    width = width / 2
  end

  return width / self[parameter .. "_sampling_rate"]
end

---
-- @tparam "random"|"inactive_custom"|"active_custom" plot
-- @treturn number
function GameSettings:plot_factor(plot)
  assert(table.find({"random", "inactive_custom", "active_custom"}, plot))

  return self[plot .. "_plot_factor"] * self:update_delay()
end

return GameSettings
