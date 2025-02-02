local luaunit = require("luaunit")
local GameSettings = require("models.gamesettings")

-- luacheck: globals TestGameSettings
TestGameSettings = {}

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
