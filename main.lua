local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local suit = require("suit")
local types = require("luaplot.types")
local iterators = require("luaplot.iterators")
local Oscillogram = require("luaplot.oscillogram")
local PlotIteratorFactory = require("luaplot.plotiteratorfactory")
local Rectangle = require("models.rectangle")
local Color = require("models.color")
local Stats = require("models.stats")
local ui = require("ui")
require("compat52")

local HORIZONTAL_SPEED = 0.2
local HORIZONTAL_STEP_COUNT = 50
local DISTANCE_SAMPLING_RATE = 50
local SOFT_DISTANCE_LIMIT = 0.33
local HARD_DISTANCE_LIMIT = 0.66
local NORMAL_DISTANCE_COLOR = Color:new(0, 1, 0, 0.25)
local SOFT_DISTANCE_LIMIT_COLOR = Color:new(1, 1, 0, 0.25)
local HARD_DISTANCE_LIMIT_COLOR = Color:new(1, 0, 0, 0.25)
local UPDATE_DELAY = 1 / (HORIZONTAL_SPEED * HORIZONTAL_STEP_COUNT)
local RANDOM_PLOT_FACTOR = 2 * UPDATE_DELAY
local CUSTOM_PLOT_FACTOR_DOWN = 0.5 * UPDATE_DELAY
local CUSTOM_PLOT_FACTOR_UP = -1 * UPDATE_DELAY

local random_plot = nil -- luaplot.Oscillogram
local custom_plot = nil -- luaplot.Oscillogram
local custom_plot_factor = CUSTOM_PLOT_FACTOR_DOWN
local custom_source_plot = nil -- luaplot.Oscillogram
local screen = nil -- models.Rectangle
local plot_line_width = 0
local horizontal_step = 0
local horizontal_offset = 0
local vertical_size = 0
local vertical_offset = 0
local boundary_size = 0
local boundary_step = 0
local distance_sampling_step = 0
local total_dt = 0
local update_counter = 0
local normal_stats = Stats:new(0, 0, 0)
local best_stats = Stats:new(0, 0, 0)
local pause_mode = false

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

local function _make_screen()
  local x, y, width, height = love.window.getSafeArea()
  return Rectangle:new(x, y, width, height)
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(_enter_fullscreen())

  random_plot = Oscillogram:new("random", HORIZONTAL_STEP_COUNT * 0.75 + 1, 0.5)
  custom_plot = Oscillogram:new("linear", HORIZONTAL_STEP_COUNT * 0.5 + 1, 0.5)
  custom_source_plot =
    Oscillogram:new("custom", HORIZONTAL_STEP_COUNT * 0.5 + 1, 0.5)

  local x, y, width, height = love.window.getSafeArea()
  screen = _make_screen()
  plot_line_width = height / 80
  horizontal_step = width / HORIZONTAL_STEP_COUNT
  horizontal_offset = x
  vertical_size = height / 1.5
  vertical_offset = y + (height - vertical_size) / 2
  boundary_size = width
  boundary_step = boundary_size / 40
  distance_sampling_step = (width / 2) / DISTANCE_SAMPLING_RATE
end

function love.draw()
  local x = 0
  for _ = 1, DISTANCE_SAMPLING_RATE do
    x = x + distance_sampling_step

    local index = x / horizontal_step + 1
    local distance = iterators.difference(random_plot, custom_plot, index, true)
    if distance < SOFT_DISTANCE_LIMIT then
      love.graphics.setColor(NORMAL_DISTANCE_COLOR:channels())
    elseif distance < HARD_DISTANCE_LIMIT then
      love.graphics.setColor(SOFT_DISTANCE_LIMIT_COLOR:channels())
    else
      love.graphics.setColor(HARD_DISTANCE_LIMIT_COLOR:channels())
    end

    love.graphics.rectangle(
      "fill",
      x - distance_sampling_step + horizontal_offset, vertical_offset,
      distance_sampling_step, vertical_size
    )
  end

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

  local iterator = PlotIteratorFactory:new(function(index, point)
    assert(types.is_number_with_limits(index, 1))
    assert(types.is_number_with_limits(point))

    return {
      x = (index - 1) * horizontal_step + horizontal_offset,
      y = point * vertical_size + vertical_offset,
    }
  end)

  local random_plot_points = {}
  for _, point in ipairs(iterator:with(random_plot)) do
    table.insert(random_plot_points, point.x)
    table.insert(random_plot_points, point.y)
  end

  love.graphics.setColor(0, 0, 0.5)
  love.graphics.setLineJoin("bevel")
  love.graphics.setLineWidth(plot_line_width)
  love.graphics.line(random_plot_points)

  local custom_source_plot_points = {}
  for _, point in ipairs(iterator:with(custom_source_plot)) do
    table.insert(custom_source_plot_points, point.x)
    table.insert(custom_source_plot_points, point.y)
  end

  love.graphics.setColor(0, 0.33, 0)
  love.graphics.setLineWidth(plot_line_width / 2)
  love.graphics.line(custom_source_plot_points)

  local custom_plot_points = {}
  for _, point in ipairs(iterator:with(custom_plot)) do
    table.insert(custom_plot_points, point.x)
    table.insert(custom_plot_points, point.y)
  end

  love.graphics.setColor(0, 0.66, 0)
  love.graphics.setLineWidth(plot_line_width)
  love.graphics.line(custom_plot_points)

  local x, y, width, height = love.window.getSafeArea()
  local font_size = height / 20
  love.graphics.setFont(love.graphics.newFont(font_size))

  if pause_mode then
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", x, y, width, height)
  end

  suit.draw()
end

function love.update(dt)
  if not pause_mode then
    total_dt = total_dt + dt
    if total_dt > UPDATE_DELAY then
      local is_custom_plot_factor_up =
        custom_plot_factor == CUSTOM_PLOT_FACTOR_UP
      random_plot:update(RANDOM_PLOT_FACTOR)
      custom_plot:update(custom_plot_factor)
      custom_source_plot:update(is_custom_plot_factor_up and 0 or 1)

      total_dt = total_dt - UPDATE_DELAY
      if update_counter < HORIZONTAL_STEP_COUNT / 2 then
        update_counter = update_counter + 1
      end
    end

    local index =
      DISTANCE_SAMPLING_RATE * distance_sampling_step / horizontal_step + 1
    local distance = iterators.difference(random_plot, custom_plot, index, true)
    local suitable_parameter
    if distance < SOFT_DISTANCE_LIMIT then
      suitable_parameter = "normal_time"
    elseif distance < HARD_DISTANCE_LIMIT then
      suitable_parameter = "soft_limit_time"
    else
      suitable_parameter = "hard_limit_time"
    end
    normal_stats[suitable_parameter] = normal_stats[suitable_parameter] + dt
  end

  if
    (best_stats:total(true) == 0 and update_counter == HORIZONTAL_STEP_COUNT / 2)
    or normal_stats:is_best(best_stats, true)
  then
    best_stats = Stats:new(normal_stats.normal_time, normal_stats.soft_limit_time, normal_stats.hard_limit_time)
  end

  local update = ui.update(screen, normal_stats, best_stats, pause_mode)
  if update.pause then
    pause_mode = not pause_mode
  end
end

function love.resize()
  screen = _make_screen()
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
