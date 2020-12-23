local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local Plot = require("luaplot.plot")
require("compat52")

local UPDATE_DELAY = 0.1

local plot = nil -- luaplot.Plot
local plot_width = 0
local horizontal_step = 0
local horizontal_offset = 0
local vertical_size = 0
local vertical_offset = 0
local boundary_size = 0
local boundary_step = 0
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
  boundary_size = width
  boundary_step = boundary_size / 40
end

function love.draw()
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.setLineWidth(plot_width / 4)
  for x = 0, boundary_size, 1.5 * boundary_step do
    for _, y in ipairs({0, vertical_size}) do
      love.graphics.line(
        x + horizontal_offset, y + vertical_offset,
        x + boundary_step + horizontal_offset, y + vertical_offset
      )
    end
  end

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
  if total_dt > UPDATE_DELAY then
    plot:shift()
    plot:push_with_random_factor(0.2)

    total_dt = total_dt - UPDATE_DELAY
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
