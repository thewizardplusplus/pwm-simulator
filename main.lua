local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local Plot = require("luaplot.plot")
require("compat52")

local HORIZONTAL_SPEED = 0.2
local HORIZONTAL_STEP_COUNT = 50
local UPDATE_DELAY = 1 / (HORIZONTAL_SPEED * HORIZONTAL_STEP_COUNT)
local CUSTOM_PLOT_FACTOR_DOWN = 0.05
local CUSTOM_PLOT_FACTOR_UP = -0.1

local random_plot = nil -- luaplot.Plot
local custom_plot = nil -- luaplot.Plot
local custom_plot_factor = CUSTOM_PLOT_FACTOR_DOWN
local custom_source_plot = nil -- luaplot.Plot
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
  for _ = 1, HORIZONTAL_STEP_COUNT * 0.75 + 1 do
    random_plot:push(0.5)
  end

  custom_plot = Plot:new(0)
  custom_source_plot = Plot:new(0)
  for _ = 1, HORIZONTAL_STEP_COUNT * 0.5 + 1 do
    custom_plot:push(0.5)
    custom_source_plot:push(0.5)
  end

  local x, y, width, height = love.window.getSafeArea()
  plot_line_width = height / 80
  horizontal_step = width / HORIZONTAL_STEP_COUNT
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

  love.graphics.setColor(0, 0, 0.5)
  love.graphics.setLineJoin("bevel")
  love.graphics.setLineWidth(plot_line_width)
  love.graphics.line(random_plot_points)

  local custom_source_plot_points = {}
  for x, y in ipairs(custom_source_plot) do
    x = (x - 1) * horizontal_step + horizontal_offset
    table.insert(custom_source_plot_points, x)

    y = y * vertical_size + vertical_offset
    table.insert(custom_source_plot_points, y)
  end

  love.graphics.setColor(0, 0.33, 0)
  love.graphics.setLineWidth(plot_line_width / 2)
  love.graphics.line(custom_source_plot_points)

  local custom_plot_points = {}
  for x, y in ipairs(custom_plot) do
    x = (x - 1) * horizontal_step + horizontal_offset
    table.insert(custom_plot_points, x)

    y = y * vertical_size + vertical_offset
    table.insert(custom_plot_points, y)
  end

  love.graphics.setColor(0, 0.66, 0)
  love.graphics.setLineWidth(plot_line_width)
  love.graphics.line(custom_plot_points)
end

function love.update(dt)
  total_dt = total_dt + dt
  if total_dt > UPDATE_DELAY then
    random_plot:shift()
    random_plot:push_with_random_factor(0.2)

    custom_plot:shift()
    custom_plot:push_with_factor(custom_plot_factor)

    local is_custom_plot_factor_up = custom_plot_factor == CUSTOM_PLOT_FACTOR_UP
    custom_source_plot:shift()
    custom_source_plot:push(is_custom_plot_factor_up and 0 or 1)

    total_dt = total_dt - UPDATE_DELAY
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed()
  custom_plot_factor = CUSTOM_PLOT_FACTOR_UP
end

function love.mousereleased()
  custom_plot_factor = CUSTOM_PLOT_FACTOR_DOWN
end
