local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local tick = require("tick")
local Rectangle = require("models.rectangle")
local StatsGroup = require("models.statsgroup")
local PlotGroup = require("models.plotgroup")
local GameSettings = require("models.gamesettings")
local drawing = require("drawing")
local ui = require("ui")
require("luatable")
require("compat52")

local settings = nil -- models.GameSettings
local screen = nil -- models.Rectangle
local plots = nil -- models.PlotGroup
local custom_plot_activity = false
local stats = StatsGroup:new()
local update_count = 0
local pause = false

local function _enter_fullscreen()
  local os = love.system.getOS()
  local is_mobile_os = table.find({"Android", "iOS"}, os)
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

local function _update_plots()
  if pause then
    return
  end

  plots:update(settings, custom_plot_activity)

  if update_count < settings:plot_length("custom") then
    update_count = update_count + 1
  end
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(_enter_fullscreen())

  settings = GameSettings:new(0.2, 50, 50, 0.33, 0.66, 2, 0.5, -1)
  screen = _make_screen()
  plots = PlotGroup:new(settings)

  tick.recur(_update_plots, settings:update_delay())
end

function love.draw()
  drawing.draw_game(settings, screen, plots, pause)
  ui.draw(screen)
end

function love.update(dt)
  tick.update(dt)

  if not pause then
    stats:increase_current(settings, plots, dt)
    if update_count == settings:plot_length("custom") then
      stats:update_best(true)
    end
  end

  local update = ui.update(screen, stats, pause)
  if update.pause then
    pause = not pause
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
