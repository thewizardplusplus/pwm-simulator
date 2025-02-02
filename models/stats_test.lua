local luaunit = require("luaunit")
local Stats = require("models.stats")

-- luacheck: globals TestStats
TestStats = {}

function TestStats.test_tostring()
  local stats = Stats:new(10, 20, 30)
  local text = tostring(stats)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Stats\"," ..
    "hard_limit_time = 30," ..
    "normal_time = 10," ..
    "soft_limit_time = 20" ..
  "}")
end
