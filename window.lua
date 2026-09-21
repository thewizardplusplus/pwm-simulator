---
-- @module window

local Rectangle = require("models.rectangle")
local Vector2D = require("luamath.vector2d")

local window = {}

---
-- @treturn bool always true
-- @error error message
function window.enter_fullscreen()
  local is_mobile_os = table.find({"Android", "iOS"}, love.system.getOS())
  if not is_mobile_os then
    return true
  end

  local ok = love.window.setFullscreen(true, "desktop")
  if not ok then
    return nil, "unable to enter fullscreen"
  end

  return true
end

---
-- @treturn Rectangle
function window.create_screen()
  local x, y, width, height = love.window.getSafeArea()
  local position = Vector2D:new(x, y)
  return Rectangle:new(position, position + Vector2D:new(width, height))
end

return window
