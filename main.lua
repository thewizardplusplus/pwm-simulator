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

local _TOUCH_RIGHT_HALF_MOVES_UP = true

local settings = nil -- models.GameSettings
local screen = nil -- models.Rectangle
local fonts = nil -- {[string]=Font,...}
local plots = nil -- models.PlotGroup
local pressed_mouse_buttons = table() -- luatable
local pressed_touches = table() -- {[userdata]="left"|"right"}
local stats_storage = nil -- StatsStorage
local stats = StatsGroup:new()
local update_count = 0
local pause = false

local function _is_pressed(button)
  return pressed_mouse_buttons:has(button)
    or pressed_touches:valueList():has(button)
end

local function _update_plots()
  if pause then
    return
  end

  local custom_plot_mode = "inactive_custom"
  -- right mouse button takes precedence
  if _is_pressed("right") then
    custom_plot_mode = "fast_inactive_custom"
  elseif _is_pressed("left") then
    custom_plot_mode = "active_custom"
  end

  plots:update(settings, custom_plot_mode)

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

  if key == "space" then
    pause = not pause
  end

  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(_, _, button, is_touch)
  assertions.is_integer(button)
  assertions.is_boolean(is_touch)

  if is_touch then
    return
  end

  if button == 1 then
    pressed_mouse_buttons = pressed_mouse_buttons:union({"left"})
  elseif button == 2 then
    pressed_mouse_buttons = pressed_mouse_buttons:union({"right"})
  end
end

function love.mousereleased(_, _, button, is_touch)
  assertions.is_integer(button)
  assertions.is_boolean(is_touch)

  if is_touch then
    return
  end

  if button == 1 then
    pressed_mouse_buttons = pressed_mouse_buttons:negation({"left"})
  elseif button == 2 then
    pressed_mouse_buttons = pressed_mouse_buttons:negation({"right"})
  end
end

function love.touchpressed(id, x)
  assertions.is_true(type(id) == "userdata")
  assertions.is_number(x)

  local is_right_half = x >= screen:center().x
  local moves_up = is_right_half == _TOUCH_RIGHT_HALF_MOVES_UP
  pressed_touches[id] = moves_up and "left" or "right"
end

function love.touchreleased(id)
  assertions.is_true(type(id) == "userdata")

  pressed_touches[id] = nil
end
