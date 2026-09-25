local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local GameSettings = require("models.gamesettings")
local PlotGroup = require("models.plotgroup")

-- luacheck: globals TestPlotGroup
TestPlotGroup = {}

function TestPlotGroup.test_tostring()
  local settings = GameSettings:new(1, 0, 1, 0.25, 0.5, 1, 5, 2, 3, 4)
  local plots = PlotGroup:new(settings)
  local text = tostring(plots)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"PlotGroup\"," ..
    "custom = {" ..
      "__name = \"Oscillogram\"," ..
      "default = 0.5," ..
      "kind = \"linear\"," ..
      "points = { 0.5 }," ..
      "range = {__name = \"Range\",max = 1,min = 0}" ..
    "}," ..
    "custom_source = {" ..
      "__name = \"Oscillogram\"," ..
      "default = 0.5," ..
      "kind = \"custom\"," ..
      "points = { 0.5 }," ..
      "range = {__name = \"Range\",max = 1,min = 0}" ..
    "}," ..
    "random = {" ..
      "__name = \"Oscillogram\"," ..
      "default = 0.5," ..
      "kind = \"random\"," ..
      "points = { 0.5 }," ..
      "range = {__name = \"Range\",max = 1,min = 0}" ..
    "}" ..
  "}")
end

function TestPlotGroup.test_update_in_fast_inactive_mode()
  math.randomseed(1)

  local settings =
    GameSettings:new(1, 2, 1, 0.25, 0.5, 0.4, 0.6, 0.2, -0.4, 1)
  local plots = PlotGroup:new(settings)
  plots:update(settings, "fast_inactive_custom")

  local last_random_point
  if _VERSION == "Lua 5.5" or _VERSION == "Lua 5.4" then
    last_random_point = 0.626235
  elseif _VERSION == "Lua 5.3" or _VERSION == "Lua 5.2" then
    last_random_point = 0.457753
  elseif _VERSION == "Lua 5.1" then
    if checks.is_table(jit) then -- check for LuaJIT
      last_random_point = 0.429524
    else
      last_random_point = 0.636075
    end
  end

  luaunit.assert_almost_equals(plots.random[2].y, last_random_point, 1e-6)
  luaunit.assert_almost_equals(plots.custom[2].y, 0.8, 1e-6)
  luaunit.assert_equals(plots.custom_source[2].y, 1)
end

function TestPlotGroup.test_update_in_inactive_mode()
  math.randomseed(1)

  local settings =
    GameSettings:new(1, 2, 1, 0.25, 0.5, 0.4, 0.6, 0.2, -0.4, 1)
  local plots = PlotGroup:new(settings)
  plots:update(settings, "inactive_custom")

  local last_random_point
  if _VERSION == "Lua 5.5" or _VERSION == "Lua 5.4" then
    last_random_point = 0.626235
  elseif _VERSION == "Lua 5.3" or _VERSION == "Lua 5.2" then
    last_random_point = 0.457753
  elseif _VERSION == "Lua 5.1" then
    if checks.is_table(jit) then -- check for LuaJIT
      last_random_point = 0.429524
    else
      last_random_point = 0.636075
    end
  end

  luaunit.assert_almost_equals(plots.random[2].y, last_random_point, 1e-6)
  luaunit.assert_almost_equals(plots.custom[2].y, 0.6, 1e-6)
  luaunit.assert_almost_equals(plots.custom_source[2].y, 2 / 3, 1e-6)
end

function TestPlotGroup.test_update_in_active_mode()
  math.randomseed(1)

  local settings =
    GameSettings:new(1, 2, 1, 0.25, 0.5, 0.4, 0.6, 0.2, -0.4, 1)
  local plots = PlotGroup:new(settings)
  plots:update(settings, "active_custom")

  local last_random_point
  if _VERSION == "Lua 5.5" or _VERSION == "Lua 5.4" then
    last_random_point = 0.626235
  elseif _VERSION == "Lua 5.3" or _VERSION == "Lua 5.2" then
    last_random_point = 0.457753
  elseif _VERSION == "Lua 5.1" then
    if checks.is_table(jit) then -- check for LuaJIT
      last_random_point = 0.429524
    else
      last_random_point = 0.636075
    end
  end

  luaunit.assert_almost_equals(plots.random[2].y, last_random_point, 1e-6)
  luaunit.assert_almost_equals(plots.custom[2].y, 0.3, 1e-6)
  luaunit.assert_almost_equals(plots.custom_source[2].y, 1 / 6, 1e-6)
end

function TestPlotGroup.test_source_levels_with_game_settings()
  local settings =
    GameSettings:new(0.2, 50, 50, 0.33, 0.66, 2, 1, 0.5, -1, 1)
  local plots = PlotGroup:new(settings)

  plots:update(settings, "active_custom")
  luaunit.assert_equals(plots.custom_source[26].y, 0)

  plots:update(settings, "inactive_custom")
  luaunit.assert_equals(plots.custom_source[26].y, 0.75)

  plots:update(settings, "fast_inactive_custom")
  luaunit.assert_equals(plots.custom_source[26].y, 1)
end
