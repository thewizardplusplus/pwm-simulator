local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local GameSettings = require("models.gamesettings")

-- luacheck: globals TestGameSettings
TestGameSettings = {}

function TestGameSettings.test_from_json_success()
  local settings, err = json.from_json(
    [[{
      "__name": "GameSettings",
      "plot_sampling_speed": 1,
      "plot_sampling_rate": 4,
      "distance_sampling_rate": 2,
      "soft_distance_limit": 0.25,
      "hard_distance_limit": 0.5,
      "random_plot_factor": 1,
      "inactive_custom_plot_factor": 2,
      "active_custom_plot_factor": 3,
      "stats_storing_delay": 4
    }]],
    GameSettings.schema(),
    { GameSettings = GameSettings.from_options }
  )

  luaunit.assert_is_table(settings)
  luaunit.assert_is_true(checks.is_instance(settings, GameSettings))

  luaunit.assert_is_number(settings.plot_sampling_speed)
  luaunit.assert_equals(settings.plot_sampling_speed, 1)

  luaunit.assert_is_true(checks.is_integer(settings.plot_sampling_rate))
  luaunit.assert_equals(settings.plot_sampling_rate, 4)

  luaunit.assert_is_true(checks.is_integer(settings.plot_sampling_rate))
  luaunit.assert_equals(settings.distance_sampling_rate, 2)

  luaunit.assert_is_number(settings.soft_distance_limit)
  luaunit.assert_equals(settings.soft_distance_limit, 0.25)

  luaunit.assert_is_number(settings.hard_distance_limit)
  luaunit.assert_equals(settings.hard_distance_limit, 0.5)

  luaunit.assert_is_number(settings.random_plot_factor)
  luaunit.assert_equals(settings.random_plot_factor, 1)

  luaunit.assert_is_number(settings.inactive_custom_plot_factor)
  luaunit.assert_equals(settings.inactive_custom_plot_factor, 2)

  luaunit.assert_is_number(settings.active_custom_plot_factor)
  luaunit.assert_equals(settings.active_custom_plot_factor, 3)

  luaunit.assert_is_number(settings.stats_storing_delay)
  luaunit.assert_equals(settings.stats_storing_delay, 4)

  luaunit.assert_is_nil(err)
end

function TestGameSettings.test_from_json_error()
  local settings, err = json.from_json(
    [[{
      "__name": "GameSettings",
      "plot_sampling_speed": "invalid",
      "plot_sampling_rate": 4,
      "distance_sampling_rate": 2,
      "soft_distance_limit": 0.25,
      "hard_distance_limit": 0.5,
      "random_plot_factor": 1,
      "inactive_custom_plot_factor": 2,
      "active_custom_plot_factor": 3,
      "stats_storing_delay": 4
    }]],
    GameSettings.schema(),
    { GameSettings = GameSettings.from_options }
  )

  luaunit.assert_is_nil(settings)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: " ..
      [[property "plot_sampling_speed" validation failed: ]] ..
      "wrong type: " ..
      "expected number, got string$"
  )
end

function TestGameSettings.test_tostring()
  local settings = GameSettings:new(1, 4, 2, 0.25, 0.5, 1, 2, 3, 4)
  local text = tostring(settings)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"GameSettings\"," ..
    "active_custom_plot_factor = 3," ..
    "distance_sampling_rate = 2," ..
    "hard_distance_limit = 0.5," ..
    "inactive_custom_plot_factor = 2," ..
    "plot_sampling_rate = 4," ..
    "plot_sampling_speed = 1," ..
    "random_plot_factor = 1," ..
    "soft_distance_limit = 0.25," ..
    "stats_storing_delay = 4" ..
  "}")
end
