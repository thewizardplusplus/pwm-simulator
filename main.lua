local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local Plot = require("luaplot.plot")
require("compat52")

local plot = nil -- luaplot.Plot
local plot_width = 0
local horizontal_step = 0
local horizontal_offset = 0
local vertical_size = 0
local vertical_offset = 0
local total_dt = 0

function love.load()
  math.randomseed(os.time())

  plot = Plot:new(0)
  for _ = 1, 16 do
    plot:push_with_random_factor(0.2)
  end

  local x, y, width, height = love.window.getSafeArea()
  plot_width = height / 80
  horizontal_step = width / 20
  horizontal_offset = x
  vertical_size = height / 1.5
  vertical_offset = y + (height - vertical_size) / 2
end

function love.draw()
  local points = {}
  for x, y in ipairs(plot) do
    x = (x - 1) * horizontal_step + horizontal_offset
    table.insert(points, x)

    y = y * vertical_size + vertical_offset
    table.insert(points, y)
  end

  love.graphics.setColor(0, 0, 1)
  love.graphics.setLineWidth(plot_width)
  love.graphics.line(points)
end

function love.update(dt)
  total_dt = total_dt + dt
  if total_dt > 0.1 then
    plot:shift()
    plot:push_with_random_factor(0.2)

    total_dt = 0
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
