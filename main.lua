local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local Rectangle = require("models.rectangle")
local StatsGroup = require("models.statsgroup")
local DistanceLimit = require("luaplot.distancelimit")
local PlotGroup = require("models.plotgroup")
local drawing = require("drawing")
local ui = require("ui")
local colors = require("constants.colors")
local iterators = require("luaplot.iterators")
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

local plots = nil -- models.PlotGroup
local custom_plot_factor = CUSTOM_PLOT_FACTOR_DOWN
local screen = nil -- models.Rectangle
local horizontal_step = 0
local vertical_size = 0
local distance_sampling_step = 0
local total_dt = 0
local update_counter = 0
local stats = StatsGroup:new()
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

  plots = PlotGroup:new(HORIZONTAL_STEP_COUNT)

  local _, _, width, height = love.window.getSafeArea()
  screen = _make_screen()
  horizontal_step = width / HORIZONTAL_STEP_COUNT
  vertical_size = height / 1.5
  distance_sampling_step = (width / 2) / DISTANCE_SAMPLING_RATE
end

function love.draw()
  drawing.draw_game(screen, vertical_size, horizontal_step, DISTANCE_SAMPLING_RATE, plots, pause_mode, {
    DistanceLimit:new(SOFT_DISTANCE_LIMIT, colors.NORMAL_DISTANCE_COLOR),
    DistanceLimit:new(HARD_DISTANCE_LIMIT, colors.SOFT_DISTANCE_LIMIT_COLOR),
    DistanceLimit:new(math.huge, colors.HARD_DISTANCE_LIMIT_COLOR),
  })

  ui.draw(screen)
end

function love.update(dt)
  if not pause_mode then
    total_dt = total_dt + dt
    if total_dt > UPDATE_DELAY then
      local is_custom_plot_factor_up =
        custom_plot_factor == CUSTOM_PLOT_FACTOR_UP
      plots.random:update(RANDOM_PLOT_FACTOR)
      plots.custom:update(custom_plot_factor)
      plots.custom_source:update(is_custom_plot_factor_up and 0 or 1)

      total_dt = total_dt - UPDATE_DELAY
      if update_counter < HORIZONTAL_STEP_COUNT / 2 then
        update_counter = update_counter + 1
      end
    end

    local index =
      DISTANCE_SAMPLING_RATE * distance_sampling_step / horizontal_step + 1
    local suitable_parameter = iterators.select_by_distance(plots.random, plots.custom, index, true, {
      DistanceLimit:new(SOFT_DISTANCE_LIMIT, "normal"),
      DistanceLimit:new(HARD_DISTANCE_LIMIT, "soft_limit"),
      DistanceLimit:new(math.huge, "hard_limit"),
    })
    stats.current:increase(suitable_parameter, dt)
  end

  if update_counter == HORIZONTAL_STEP_COUNT / 2 then
    stats:update(true)
  end

  local update = ui.update(screen, vertical_size, stats, pause_mode)
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
