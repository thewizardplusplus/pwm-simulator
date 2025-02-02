local luaunit = require("luaunit")
local Stats = require("models.stats")
local StatsGroup = require("models.statsgroup")

-- luacheck: globals TestStatsGroup
TestStatsGroup = {}

function TestStatsGroup.test_tostring()
  local stats_group = StatsGroup:new()
  stats_group.current = Stats:new(10, 20, 30)
  stats_group.best = Stats:new(40, 50, 60)

  local text = tostring(stats_group)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"StatsGroup\"," ..
    "best = {" ..
      "__name = \"Stats\"," ..
      "hard_limit_time = 60," ..
      "normal_time = 40," ..
      "soft_limit_time = 50" ..
    "}," ..
    "current = {" ..
      "__name = \"Stats\"," ..
      "hard_limit_time = 30," ..
      "normal_time = 10," ..
      "soft_limit_time = 20" ..
    "}" ..
  "}")
end
