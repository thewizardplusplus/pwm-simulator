local luaunit = require("luaunit")
local GameSettings = require("models.gamesettings")
local PlotGroup = require("models.plotgroup")

-- luacheck: globals TestPlotGroup
TestPlotGroup = {}

function TestPlotGroup.test_tostring()
  local settings = GameSettings:new(1, 0, 1, 0.25, 0.5, 1, 2, 3, 4)
  local plots = PlotGroup:new(settings)
  local text = tostring(plots)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"PlotGroup\"," ..
    "custom = {" ..
      "__name = \"Oscillogram\"," ..
      "default = 0.5," ..
      "kind = \"linear\"," ..
      "maximum = 1," ..
      "minimum = 0," ..
      "points = { 0.5 }" ..
    "}," ..
    "custom_source = {" ..
      "__name = \"Oscillogram\"," ..
      "default = 0.5," ..
      "kind = \"custom\"," ..
      "maximum = 1," ..
      "minimum = 0," ..
      "points = { 0.5 }" ..
    "}," ..
    "random = {" ..
      "__name = \"Oscillogram\"," ..
      "default = 0.5," ..
      "kind = \"random\"," ..
      "maximum = 1," ..
      "minimum = 0," ..
      "points = { 0.5 }" ..
    "}" ..
  "}")
end
