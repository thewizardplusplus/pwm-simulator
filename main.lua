local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local Rectangle = require("models.rectangle")
local StatsGroup = require("models.statsgroup")
local PlotGroup = require("models.plotgroup")
local GameSettings = require("models.gamesettings")
local drawing = require("drawing")
local ui = require("ui")
require("compat52")

local settings = nil -- models.GameSettings
local screen = nil -- models.Rectangle
local plots = nil -- models.PlotGroup
local custom_plot_activity = false
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

  settings = GameSettings:new(0.2, 50, 50, 0.33, 0.66, 2, 0.5, -1)
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
    if total_dt > settings:update_delay() then
      plots.random:update(settings:plot_factor("random"))
      plots.custom:update(settings:plot_factor(custom_plot_activity and "active_custom" or "inactive_custom"))
      plots.custom_source:update(custom_plot_activity and 0 or 1)

      total_dt = total_dt - settings:update_delay()
      if update_counter < settings:plot_length("custom") then
        update_counter = update_counter + 1
      end
    end

    stats:increase_current(settings, plots, dt)
    if update_counter == settings:plot_length("custom") then
      stats:update_best(true)
    end
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
  custom_plot_activity = true
end

function love.mousereleased()
  custom_plot_activity = false
end
