local luaunit = require("luaunit")
local UiUpdate = require("models.uiupdate")

-- luacheck: globals TestUiUpdate
TestUiUpdate = {}

function TestUiUpdate.test_tostring()
  local update = UiUpdate:new(true)
  local text = tostring(update)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{__name = \"UiUpdate\",pause = true}")
end
