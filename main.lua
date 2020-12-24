local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local Plot = require("luaplot.plot")
require("compat52")

local UPDATE_DELAY = 0.1

local random_plot = nil -- luaplot.Plot
local custom_plot = nil -- luaplot.Plot
local plot_line_width = 0
local horizontal_step = 0
local horizontal_offset = 0
local vertical_size = 0
local vertical_offset = 0
local boundary_size = 0
local boundary_step = 0
local total_dt = 0

local function _enter_fullscreen()
  local is_mobile_os = love.system.getOS() == "Android"
    or love.system.getOS() == "iOS"
  if not is_mobile_os then
    return true
  end

  local ok = love.window.setFullscreen(true, "desktop")
  if not ok then
    return false, "unable to enter fullscreen"
  end

  return true
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(_enter_fullscreen())

  random_plot = Plot:new(0)
  for _ = 1, 16 do
    random_plot:push(0.5)
  end

  custom_plot = Plot:new(0)
  for _ = 1, 11 do
    custom_plot:push(0.5)
  end

  local x, y, width, height = love.window.getSafeArea()
  plot_line_width = height / 80
  horizontal_step = width / 20
  horizontal_offset = x
  vertical_size = height / 1.5
  vertical_offset = y + (height - vertical_size) / 2
  boundary_size = width
  boundary_step = boundary_size / 40
end

function love.draw()
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.setLineWidth(plot_line_width / 4)
  for x = 0, boundary_size, 1.5 * boundary_step do
    for _, y in ipairs({0, vertical_size}) do
      love.graphics.line(
        x + horizontal_offset, y + vertical_offset,
        x + boundary_step + horizontal_offset, y + vertical_offset
      )
    end
  end

  local random_plot_points = {}
  for x, y in ipairs(random_plot) do
    x = (x - 1) * horizontal_step + horizontal_offset
    table.insert(random_plot_points, x)

    y = y * vertical_size + vertical_offset
    table.insert(random_plot_points, y)
  end

  love.graphics.setColor(0, 0, 1)
  love.graphics.setLineWidth(plot_line_width)
  love.graphics.line(random_plot_points)

  local custom_plot_points = {}
  for x, y in ipairs(custom_plot) do
    x = (x - 1) * horizontal_step + horizontal_offset
    table.insert(custom_plot_points, x)

    y = y * vertical_size + vertical_offset
    table.insert(custom_plot_points, y)
  end

  love.graphics.setColor(0, 0.66, 0)
  love.graphics.line(custom_plot_points)
end

function love.update(dt)
  total_dt = total_dt + dt
  if total_dt > UPDATE_DELAY then
    random_plot:shift()
    random_plot:push_with_random_factor(0.2)

    total_dt = total_dt - UPDATE_DELAY
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end
