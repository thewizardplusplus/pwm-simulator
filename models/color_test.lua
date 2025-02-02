local luaunit = require("luaunit")
local Color = require("models.color")

-- luacheck: globals TestColor
TestColor = {}

function TestColor.test_tostring()
  local color = Color:new(0.1, 0.2, 0.3, 0.4)
  local text = tostring(color)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Color\"," ..
    "alpha = 0.4," ..
    "blue = 0.3," ..
    "green = 0.2," ..
    "red = 0.1" ..
  "}")
end
