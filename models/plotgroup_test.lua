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
