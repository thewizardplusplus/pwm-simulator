local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local tick = require("tick")
local assertions = require("luatypechecks.assertions")
local StatsGroup = require("models.statsgroup")
local PlotGroup = require("models.plotgroup")
local factory = require("factory")
local drawing = require("drawing")
local ui = require("ui")
local window = require("window")
local StatsStorage = require("statsstorage")
require("luatable")

local settings = nil -- models.GameSettings
local screen = nil -- models.Rectangle
local fonts = nil -- {[string]=Font,...}
local plots = nil -- models.PlotGroup
local custom_plot_activity = false
local stats_storage = nil -- StatsStorage
local stats = StatsGroup:new()
local update_count = 0
local pause = false

local function _update_plots()
  if pause then
    return
  end

  plots:update(settings, custom_plot_activity)

  if update_count < settings:plot_length("custom") then
    update_count = update_count + 1
  end
end

local function _update_stats()
  if update_count < settings:plot_length("custom") then
    return
  end

  stats_storage:store_stats(stats.best)
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(window.enter_fullscreen())

  settings = assert(factory.create_game_settings("settings.json"))
  screen = window.create_screen()
  fonts = ui.load_fonts(screen)
  plots = PlotGroup:new(settings)
  stats_storage = StatsStorage:new("stats.json")
  stats.best = stats_storage:stats()

  tick.recur(_update_plots, settings:update_delay())
  tick.recur(_update_stats, settings.stats_storing_delay)
end

function love.draw()
  drawing.draw_game(settings, screen, plots, pause)
  ui.draw()
end

function love.update(dt)
  assertions.is_number(dt)

  tick.update(dt)

  if not pause then
    stats:increase_current(settings, plots, dt)
    if update_count == settings:plot_length("custom") then
      stats:update_best(true)
    end
  end

  local update = ui.update(screen, fonts, stats, pause)
  if update.pause then
    pause = not pause
  end
end

function love.resize()
  screen = window.create_screen()
  fonts = ui.load_fonts(screen)
end

function love.keypressed(key)
  assertions.is_string(key)

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
