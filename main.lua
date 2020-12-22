local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local Plot = require("luaplot.plot")
require("compat52")

local plot = nil -- luaplot.Plot

function love.load()
  math.randomseed(os.time())

  plot = Plot:new(0)
  for _ = 1, 10 do
    plot:push_with_random_factor(0.2)
  end
end

function love.draw()
  local points = {}
  for x, y in ipairs(plot) do
    x = x * 10
    table.insert(points, x)

    y = y * 100 + 100
    table.insert(points, y)
  end

  love.graphics.line(points)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
