---
-- @module factory

local typeutils = require("typeutils")
local assertions = require("luatypechecks.assertions")
local GameSettings = require("models.gamesettings")
local StatsStorage = require("statsstorage")

local factory = {}

---
-- @tparam string path
-- @treturn GameSettings
-- @error error message
function factory.create_game_settings(path)
  assertions.is_string(path)

  local data, loading_err = typeutils.load_json(path, {
    type = "object",
    required = {
      "plot_sampling_speed",
      "plot_sampling_rate",
      "distance_sampling_rate",
      "soft_distance_limit",
      "hard_distance_limit",
      "random_plot_factor",
      "inactive_custom_plot_factor",
      "active_custom_plot_factor",
      "stats_storing_delay",
    },
    properties = {
      plot_sampling_speed = { ["$ref"] = "#/definitions/positive_number" },
      plot_sampling_rate = { ["$ref"] = "#/definitions/positive_integer" },
      distance_sampling_rate = { ["$ref"] = "#/definitions/positive_integer" },
      soft_distance_limit = { ["$ref"] = "#/definitions/percents" },
      hard_distance_limit = { ["$ref"] = "#/definitions/percents" },
      random_plot_factor = { ["$ref"] = "#/definitions/positive_number" },
      inactive_custom_plot_factor = { type = "number" },
      active_custom_plot_factor = { type = "number" },
      stats_storing_delay = { ["$ref"] = "#/definitions/positive_number" },
    },
    definitions = {
      positive_number = { type = "number", minimum = 0 },
      positive_integer = { type = "number", minimum = 0, multipleOf = 1 },
      percents = { type = "number", minimum = 0, maximum = 1 },
    },
  })
  if not data then
    return nil, "unable to load the game settings: " .. loading_err
  end

  return GameSettings:new(
    data.plot_sampling_speed,
    data.plot_sampling_rate,
    data.distance_sampling_rate,
    data.soft_distance_limit,
    data.hard_distance_limit,
    data.random_plot_factor,
    data.inactive_custom_plot_factor,
    data.active_custom_plot_factor,
    data.stats_storing_delay
  )
end

---
-- @tparam string path
-- @treturn StatsStorage
-- @error error message
function factory.create_stats_storage(path)
  assertions.is_string(path)

  local ok = love.filesystem.createDirectory(path)
  if not ok then
    return nil, "unable to create the stats DB"
  end

  local full_path = love.filesystem.getSaveDirectory() .. "/" .. path
  return StatsStorage:new(full_path)
end

return factory
