local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local suit = require("suit")
local types = require("luaplot.types")
local iterators = require("luaplot.iterators")
local Oscillogram = require("luaplot.oscillogram")
local PlotIteratorFactory = require("luaplot.plotiteratorfactory")
require("compat52")

local HORIZONTAL_SPEED = 0.2
local HORIZONTAL_STEP_COUNT = 50
local DISTANCE_SAMPLING_RATE = 50
local SOFT_DISTANCE_LIMIT = 0.33
local HARD_DISTANCE_LIMIT = 0.66
local NORMAL_DISTANCE_COLOR = {0, 1, 0, 0.25}
local SOFT_DISTANCE_LIMIT_COLOR = {1, 1, 0, 0.25}
local HARD_DISTANCE_LIMIT_COLOR = {1, 0, 0, 0.25}
local UPDATE_DELAY = 1 / (HORIZONTAL_SPEED * HORIZONTAL_STEP_COUNT)
local RANDOM_PLOT_FACTOR = 2 * UPDATE_DELAY
local CUSTOM_PLOT_FACTOR_DOWN = 0.5 * UPDATE_DELAY
local CUSTOM_PLOT_FACTOR_UP = -1 * UPDATE_DELAY

local random_plot = nil -- luaplot.Oscillogram
local custom_plot = nil -- luaplot.Oscillogram
local custom_plot_factor = CUSTOM_PLOT_FACTOR_DOWN
local custom_source_plot = nil -- luaplot.Oscillogram
local plot_line_width = 0
local horizontal_step = 0
local horizontal_offset = 0
local vertical_size = 0
local vertical_offset = 0
local boundary_size = 0
local boundary_step = 0
local distance_sampling_step = 0
local total_dt = 0
local normal_time = 0
local soft_limit_time = 0
local hard_limit_time = 0
local best_normal_time = 0
local best_soft_limit_time = 0
local best_hard_limit_time = 0

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

local function _create_label_options(color, align)
  assert(type(color) == "table")
  assert(align == "left" or align == "right")

  return {
    color = {normal = {fg = color}},
    align = align,
    valign = "top",
  }
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
      love.graphics.setColor(NORMAL_DISTANCE_COLOR)
    elseif distance < HARD_DISTANCE_LIMIT then
      love.graphics.setColor(SOFT_DISTANCE_LIMIT_COLOR)
    else
      love.graphics.setColor(HARD_DISTANCE_LIMIT_COLOR)
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

  local _, _, _, height = love.window.getSafeArea()
  local font_size = height / 20
  love.graphics.setFont(love.graphics.newFont(font_size))

  suit.draw()
end

function love.update(dt)
  total_dt = total_dt + dt
  if total_dt > UPDATE_DELAY then
    local is_custom_plot_factor_up = custom_plot_factor == CUSTOM_PLOT_FACTOR_UP
    random_plot:update(RANDOM_PLOT_FACTOR)
    custom_plot:update(custom_plot_factor)
    custom_source_plot:update(is_custom_plot_factor_up and 0 or 1)

    total_dt = total_dt - UPDATE_DELAY
  end

  local index =
    DISTANCE_SAMPLING_RATE * distance_sampling_step / horizontal_step + 1
  local distance = iterators.difference(random_plot, custom_plot, index, true)
  if distance < SOFT_DISTANCE_LIMIT then
    normal_time = normal_time + dt
  elseif distance < HARD_DISTANCE_LIMIT then
    soft_limit_time = soft_limit_time + dt
  else
    hard_limit_time = hard_limit_time + dt
  end

  local total_time = normal_time + soft_limit_time + hard_limit_time
  local best_total_time =
    best_normal_time + best_soft_limit_time + best_hard_limit_time
  if
    (best_total_time == 0 and normal_time ~= total_time)
    or normal_time / total_time > best_normal_time / best_total_time
    or (normal_time / total_time == best_normal_time / best_total_time
      and soft_limit_time / total_time > best_soft_limit_time / best_total_time)
  then
    best_normal_time = normal_time
    best_soft_limit_time = soft_limit_time
    best_hard_limit_time = hard_limit_time
  end
  if best_total_time == 0 then
    best_total_time = 1
  end

  local _, _, _, height = love.window.getSafeArea()
  local grid_step = height / 12
  local padding = grid_step / 2

  suit.layout:reset(
    horizontal_offset + grid_step / 2,
    vertical_offset - 1.75 * grid_step
  )
  suit.Label(
    "Best:",
    _create_label_options({0.5, 0.5, 0.5}, "left"),
    suit.layout:col(1.7 * grid_step, grid_step)
  )

  local best_normal_result = best_normal_time / best_total_time * 100
  local best_normal_label_width
  if best_normal_result >= 100 then
    best_normal_label_width = 2.75 * grid_step
  elseif best_normal_result >= 10 then
    best_normal_label_width = 2.4 * grid_step
  else
    best_normal_label_width = 2 * grid_step
  end
  suit.layout:padding(padding)
  suit.Label(
    "#",
    _create_label_options(NORMAL_DISTANCE_COLOR, "left"),
    suit.layout:col(0.75 * grid_step, grid_step)
  )
  suit.layout:padding(0)
  suit.Label(
    string.format("%.2f%%", best_normal_result),
    _create_label_options({0.5, 0.5, 0.5}, "right"),
    suit.layout:col(best_normal_label_width, grid_step)
  )

  local best_soft_limit_result = best_soft_limit_time / best_total_time * 100
  local best_soft_limit_label_width
  if best_soft_limit_result >= 100 then
    best_soft_limit_label_width = 2.75 * grid_step
  elseif best_soft_limit_result >= 10 then
    best_soft_limit_label_width = 2.4 * grid_step
  else
    best_soft_limit_label_width = 2 * grid_step
  end
  suit.layout:padding(padding)
  suit.Label(
    "#",
    _create_label_options(SOFT_DISTANCE_LIMIT_COLOR, "left"),
    suit.layout:col(0.75 * grid_step, grid_step)
  )
  suit.layout:padding(0)
  suit.Label(
    string.format("%.2f%%", best_soft_limit_result),
    _create_label_options({0.5, 0.5, 0.5}, "right"),
    suit.layout:col(best_soft_limit_label_width, grid_step)
  )

  local best_hard_limit_result = best_hard_limit_time / best_total_time * 100
  local best_hard_limit_label_width
  if best_hard_limit_result >= 100 then
    best_hard_limit_label_width = 2.75 * grid_step
  elseif best_hard_limit_result >= 10 then
    best_hard_limit_label_width = 2.4 * grid_step
  else
    best_hard_limit_label_width = 2 * grid_step
  end
  suit.layout:padding(padding)
  suit.Label(
    "#",
    _create_label_options(HARD_DISTANCE_LIMIT_COLOR, "left"),
    suit.layout:col(0.75 * grid_step, grid_step)
  )
  suit.layout:padding(0)
  suit.Label(
    string.format("%.2f%%", best_hard_limit_result),
    _create_label_options({0.5, 0.5, 0.5}, "right"),
    suit.layout:col(best_hard_limit_label_width, grid_step)
  )

  suit.layout:reset(
    horizontal_offset + grid_step / 2,
    vertical_offset - grid_step
  )
  suit.Label(
    "Now:",
    _create_label_options({0.5, 0.5, 0.5}, "left"),
    suit.layout:col(1.7 * grid_step, grid_step)
  )

  local normal_result = normal_time / total_time * 100
  local normal_label_width
  if normal_result >= 100 then
    normal_label_width = 2.75 * grid_step
  elseif normal_result >= 10 then
    normal_label_width = 2.4 * grid_step
  else
    normal_label_width = 2 * grid_step
  end
  suit.layout:padding(padding)
  suit.Label(
    "#",
    _create_label_options(NORMAL_DISTANCE_COLOR, "left"),
    suit.layout:col(0.75 * grid_step, grid_step)
  )
  suit.layout:padding(0)
  suit.Label(
    string.format("%.2f%%", normal_result),
    _create_label_options({0.5, 0.5, 0.5}, "right"),
    suit.layout:col(normal_label_width, grid_step)
  )

  local soft_limit_result = soft_limit_time / total_time * 100
  local soft_limit_label_width
  if soft_limit_result >= 100 then
    soft_limit_label_width = 2.75 * grid_step
  elseif soft_limit_result >= 10 then
    soft_limit_label_width = 2.4 * grid_step
  else
    soft_limit_label_width = 2 * grid_step
  end
  suit.layout:padding(padding)
  suit.Label(
    "#",
    _create_label_options(SOFT_DISTANCE_LIMIT_COLOR, "left"),
    suit.layout:col(0.75 * grid_step, grid_step)
  )
  suit.layout:padding(0)
  suit.Label(
    string.format("%.2f%%", soft_limit_result),
    _create_label_options({0.5, 0.5, 0.5}, "right"),
    suit.layout:col(soft_limit_label_width, grid_step)
  )

  local hard_limit_result = hard_limit_time / total_time * 100
  local hard_limit_label_width
  if hard_limit_result >= 100 then
    hard_limit_label_width = 2.75 * grid_step
  elseif hard_limit_result >= 10 then
    hard_limit_label_width = 2.4 * grid_step
  else
    hard_limit_label_width = 2 * grid_step
  end
  suit.layout:padding(padding)
  suit.Label(
    "#",
    _create_label_options(HARD_DISTANCE_LIMIT_COLOR, "left"),
    suit.layout:col(0.75 * grid_step, grid_step)
  )
  suit.layout:padding(0)
  suit.Label(
    string.format("%.2f%%", hard_limit_result),
    _create_label_options({0.5, 0.5, 0.5}, "right"),
    suit.layout:col(hard_limit_label_width, grid_step)
  )
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
