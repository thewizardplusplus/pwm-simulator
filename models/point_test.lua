local luaunit = require("luaunit")
local Point = require("models.point")

-- luacheck: globals TestPoint
TestPoint = {}

function TestPoint.test_tostring()
  local point = Point:new(10, 20)
  local text = tostring(point)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Point\"," ..
    "x = 10," ..
    "y = 20" ..
  "}")
end
