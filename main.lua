local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local Rectangle = require("models.rectangle")
local StatsGroup = require("models.statsgroup")
local DistanceLimit = require("luaplot.distancelimit")
local PlotGroup = require("models.plotgroup")
local GameSettings = require("models.gamesettings")
local drawing = require("drawing")
local ui = require("ui")
local iterators = require("luaplot.iterators")
require("compat52")

local HORIZONTAL_SPEED = 0.2
local HORIZONTAL_STEP_COUNT = 50
local UPDATE_DELAY = 1 / (HORIZONTAL_SPEED * HORIZONTAL_STEP_COUNT)
local RANDOM_PLOT_FACTOR = 2 * UPDATE_DELAY
local CUSTOM_PLOT_FACTOR_DOWN = 0.5 * UPDATE_DELAY
local CUSTOM_PLOT_FACTOR_UP = -1 * UPDATE_DELAY

local settings = nil -- models.GameSettings
local screen = nil -- models.Rectangle
local plots = nil -- models.PlotGroup
local custom_plot_factor = CUSTOM_PLOT_FACTOR_DOWN
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

  settings = GameSettings:new(
    HORIZONTAL_STEP_COUNT,
    50,
    0.33,
    0.66
  )
  screen = _make_screen()
  plots = PlotGroup:new(settings)
end

function love.draw()
  drawing.draw_game(settings, screen, plots, pause_mode)
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
      if update_counter < settings:plot_length("custom") then
        update_counter = update_counter + 1
      end
    end

    local index = settings:plot_length("custom")
    local suitable_parameter = iterators.select_by_distance(plots.random, plots.custom, index, true, {
      DistanceLimit:new(settings.soft_distance_limit, "normal"),
      DistanceLimit:new(settings.hard_distance_limit, "soft_limit"),
      DistanceLimit:new(math.huge, "hard_limit"),
    })
    stats.current:increase(suitable_parameter, dt)
  end

  if update_counter == settings:plot_length("custom") then
    stats:update(true)
  end

  local update = ui.update(screen, stats, pause_mode)
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
