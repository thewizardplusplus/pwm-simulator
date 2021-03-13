local require_paths =
  {"?.lua", "?/init.lua", "vendor/?.lua", "vendor/?/init.lua"}
love.filesystem.setRequirePath(table.concat(require_paths, ";"))

local tick = require("tick")
local typeutils = require("typeutils")
local Rectangle = require("models.rectangle")
local StatsGroup = require("models.statsgroup")
local PlotGroup = require("models.plotgroup")
local GameSettings = require("models.gamesettings")
local StatsStorage = require("statsstorage")
local drawing = require("drawing")
local ui = require("ui")
require("luatable")
require("compat52")

local settings = nil -- models.GameSettings
local screen = nil -- models.Rectangle
local plots = nil -- models.PlotGroup
local custom_plot_activity = false
local stats_storage = nil -- StatsStorage
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

local function _load_game_settings(path)
  assert(type(path) == "string")

  local data, loading_err = typeutils.load_json(path, {
    type = "object",
    required = {
      "plot_sampling_speed",
      "plot_sampling_rate",
      "distance_sampling_rate",
      "soft_distance_limit",
      "hard_distance_limit",
      "random_plot_factor",
      "inactive_custom_plot_factor",
      "active_custom_plot_factor",
    },
    properties = {
      plot_sampling_speed = {
        type = "number",
        minimum = 0,
      },
      plot_sampling_rate = {
        type = "number",
        minimum = 0,
        multipleOf = 1,
      },
      distance_sampling_rate = {
        type = "number",
        minimum = 0,
        multipleOf = 1,
      },
      soft_distance_limit = {
        type = "number",
        minimum = 0,
        maximum = 1,
      },
      hard_distance_limit = {
        type = "number",
        minimum = 0,
        maximum = 1,
      },
      random_plot_factor = {
        type = "number",
        minimum = 0,
      },
      inactive_custom_plot_factor = {
        type = "number",
      },
      active_custom_plot_factor = {
        type = "number",
      },
    },
  })
  if not data then
    return nil, "unable to load the game settings: " .. loading_err
  end

  return GameSettings:new(
    data.plot_sampling_speed,
    data.plot_sampling_rate,
    data.distance_sampling_rate,
    data.soft_distance_limit,
    data.hard_distance_limit,
    data.random_plot_factor,
    data.inactive_custom_plot_factor,
    data.active_custom_plot_factor
  )
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

local function _update_stats()
  if update_count < settings:plot_length("custom") then
    return
  end

  stats_storage:store_stats(stats.best)
end

function love.load()
  math.randomseed(os.time())
  love.setDeprecationOutput(true)
  assert(_enter_fullscreen())

  settings = assert(_load_game_settings("game_settings.json"))
  screen = _make_screen()
  plots = PlotGroup:new(settings)
  stats_storage = assert(StatsStorage.create("stats-db"))
  stats.best = stats_storage:get_stats()

  tick.recur(_update_plots, settings:update_delay())
  tick.recur(_update_stats, 1)
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
