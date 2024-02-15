---
-- @classmod GameSettings

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
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
-- @tfield number stats_storing_delay

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
-- @tparam number stats_storing_delay [0, ∞)
-- @treturn GameSettings
function GameSettings:initialize(
  plot_sampling_speed,
  plot_sampling_rate,
  distance_sampling_rate,
  soft_distance_limit,
  hard_distance_limit,
  random_plot_factor,
  inactive_custom_plot_factor,
  active_custom_plot_factor,
  stats_storing_delay
)
  assertions.is_number(plot_sampling_speed)
  assertions.is_integer(plot_sampling_rate)
  assertions.is_integer(distance_sampling_rate)
  assertions.is_number(soft_distance_limit)
  assertions.is_number(hard_distance_limit)
  assertions.is_number(random_plot_factor)
  assertions.is_number(inactive_custom_plot_factor)
  assertions.is_number(active_custom_plot_factor)
  assertions.is_number(stats_storing_delay)

  self.plot_sampling_speed = plot_sampling_speed
  self.plot_sampling_rate = plot_sampling_rate
  self.distance_sampling_rate = distance_sampling_rate
  self.soft_distance_limit = soft_distance_limit
  self.hard_distance_limit = hard_distance_limit
  self.random_plot_factor = random_plot_factor
  self.inactive_custom_plot_factor = inactive_custom_plot_factor
  self.active_custom_plot_factor = active_custom_plot_factor
  self.stats_storing_delay = stats_storing_delay
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
  assertions.is_enumeration(plot, {"random", "custom"})

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
  assertions.is_instance(screen, Rectangle)
  assertions.is_enumeration(parameter, {"plot", "distance"})

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
  assertions.is_enumeration(
    plot,
    {"random", "inactive_custom", "active_custom"}
  )

  return self[plot .. "_plot_factor"] * self:update_delay()
end

return GameSettings
