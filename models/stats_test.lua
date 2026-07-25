local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local json = require("luaserialization.json")
local Stats = require("models.stats")

-- luacheck: globals TestStats
TestStats = {}

function TestStats.test_from_json_success()
  local stats, err = json.from_json(
    [[{
      "__name": "Stats",
      "normal_time": 10,
      "soft_limit_time": 20,
      "hard_limit_time": 30
    }]],
    Stats.schema(),
    { Stats = Stats.from_options }
  )

  luaunit.assert_is_table(stats)
  luaunit.assert_is_true(checks.is_instance(stats, Stats))

  luaunit.assert_is_number(stats.normal_time)
  luaunit.assert_equals(stats.normal_time, 10)

  luaunit.assert_is_number(stats.soft_limit_time)
  luaunit.assert_equals(stats.soft_limit_time, 20)

  luaunit.assert_is_number(stats.hard_limit_time)
  luaunit.assert_equals(stats.hard_limit_time, 30)

  luaunit.assert_is_nil(err)
end

function TestStats.test_from_json_error()
  local stats, err = json.from_json(
    [[{
      "__name": "Stats",
      "normal_time": "invalid",
      "soft_limit_time": 20,
      "hard_limit_time": 30
    }]],
    Stats.schema(),
    { Stats = Stats.from_options }
  )

  luaunit.assert_is_nil(stats)

  luaunit.assert_is_string(err)
  luaunit.assert_str_matches(
    err,
    "^invalid data: " ..
      [[property "normal_time" validation failed: ]] ..
      "wrong type: " ..
      "expected number, got string$"
  )
end

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
