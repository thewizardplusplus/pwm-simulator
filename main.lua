local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local iterators = require("luaplot.iterators")
local Oscillogram = require("luaplot.oscillogram")
local Rectangle = require("models.rectangle")
local Stats = require("models.stats")
local drawing = require("drawing")
local ui = require("ui")
local colors = require("constants.colors")
require("compat52")

local HORIZONTAL_SPEED = 0.2
local HORIZONTAL_STEP_COUNT = 50
local DISTANCE_SAMPLING_RATE = 50
local SOFT_DISTANCE_LIMIT = 0.33
local HARD_DISTANCE_LIMIT = 0.66
local UPDATE_DELAY = 1 / (HORIZONTAL_SPEED * HORIZONTAL_STEP_COUNT)
local RANDOM_PLOT_FACTOR = 2 * UPDATE_DELAY
local CUSTOM_PLOT_FACTOR_DOWN = 0.5 * UPDATE_DELAY
local CUSTOM_PLOT_FACTOR_UP = -1 * UPDATE_DELAY

local random_plot = nil -- luaplot.Oscillogram
local custom_plot = nil -- luaplot.Oscillogram
local custom_plot_factor = CUSTOM_PLOT_FACTOR_DOWN
local custom_source_plot = nil -- luaplot.Oscillogram
local screen = nil -- models.Rectangle
local horizontal_step = 0
local horizontal_offset = 0
local vertical_size = 0
local vertical_offset = 0
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
  horizontal_step = width / HORIZONTAL_STEP_COUNT
  horizontal_offset = x
  vertical_size = height / 1.5
  vertical_offset = y + (height - vertical_size) / 2
  distance_sampling_step = (width / 2) / DISTANCE_SAMPLING_RATE
end

function love.draw()
  local x = 0
  for _ = 1, DISTANCE_SAMPLING_RATE do
    x = x + distance_sampling_step

    local index = x / horizontal_step + 1
    local distance = iterators.difference(random_plot, custom_plot, index, true)
    local suitable_color
    if distance < SOFT_DISTANCE_LIMIT then
      suitable_color = colors.NORMAL_DISTANCE_COLOR
    elseif distance < HARD_DISTANCE_LIMIT then
      suitable_color = colors.SOFT_DISTANCE_LIMIT_COLOR
    else
      suitable_color = colors.HARD_DISTANCE_LIMIT_COLOR
    end
    love.graphics.setColor(suitable_color:channels())

    love.graphics.rectangle(
      "fill",
      x - distance_sampling_step + horizontal_offset, vertical_offset,
      distance_sampling_step, vertical_size
    )
  end

  drawing._draw_boundaries(screen, vertical_size)

  drawing._draw_plots(screen, vertical_size, horizontal_step, random_plot, custom_source_plot, custom_plot)

  if pause_mode then
    drawing._draw_pause_background(screen)
  end

  ui.draw(screen)
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
      suitable_parameter = "normal"
    elseif distance < HARD_DISTANCE_LIMIT then
      suitable_parameter = "soft_limit"
    else
      suitable_parameter = "hard_limit"
    end
    normal_stats:increase(suitable_parameter, dt)
  end

  if
    (best_stats:total(true) == 0 and update_counter == HORIZONTAL_STEP_COUNT / 2)
    or normal_stats:is_best(best_stats, true)
  then
    best_stats = normal_stats:copy()
  end

  local update = ui.update(screen, vertical_size, normal_stats, best_stats, pause_mode)
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
