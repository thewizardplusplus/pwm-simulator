---
-- @module drawing

local types = require("luaplot.types")
local iterators = require("luaplot.iterators")
local colors = require("constants.colors")
local Plot = require("luaplot.plot")
local PlotIteratorFactory = require("luaplot.plotiteratorfactory")
local DistanceLimit = require("luaplot.distancelimit")
local PlotGroup = require("models.plotgroup")
local Color = require("models.color")
local Rectangle = require("models.rectangle")
local Point = require("models.point")
local GameSettings = require("models.gamesettings")

local drawing = {}

---
-- @tparam GameSettings settings
-- @tparam Rectangle screen
-- @tparam PlotGroup plots
-- @tparam bool pause
function drawing.draw_game(settings, screen, plots, pause)
  assert(types.is_instance(settings, GameSettings))
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_instance(plots, PlotGroup))
  assert(type(pause) == "boolean")

  drawing._draw_distance(settings, screen, plots)
  drawing._draw_boundaries(screen)
  drawing._draw_plots(settings, screen, plots)
  if pause then
    drawing._draw_pause_background(screen)
  end
end

---
-- @tparam GameSettings settings
-- @tparam Rectangle screen
-- @tparam PlotGroup plots
function drawing._draw_distance(settings, screen, plots)
  assert(types.is_instance(settings, GameSettings))
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_instance(plots, PlotGroup))

  local x = 0
  for _ = 1, settings.distance_sampling_rate do
    x = x + settings:step(screen, "distance")

    local index = math.floor(x / settings:step(screen, "plot") + 1)
    local suitable_color =
      iterators.select_by_distance(plots.random, plots.custom, index, true, {
        DistanceLimit:new(
          settings.soft_distance_limit,
          colors.NORMAL_DISTANCE_COLOR
        ),
        DistanceLimit:new(
          settings.hard_distance_limit,
          colors.SOFT_DISTANCE_LIMIT_COLOR
        ),
        DistanceLimit:new(math.huge, colors.HARD_DISTANCE_LIMIT_COLOR),
      })
    love.graphics.setColor(suitable_color:channels())

    love.graphics.rectangle(
      "fill",
      screen.x + x - settings:step(screen, "distance"),
      screen:vertical_offset(),
      settings:step(screen, "distance"),
      screen:plot_height()
    )
  end
end

---
-- @tparam Rectangle screen
function drawing._draw_boundaries(screen)
  assert(types.is_instance(screen, Rectangle))

  local boundary_line_width = screen.height / 320
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.setLineWidth(boundary_line_width)

  local boundary_step = screen.width / 40
  for x = 0, screen.width, 1.5 * boundary_step do
    for _, y in ipairs({0, screen:plot_height()}) do
      love.graphics.line(
        screen.x + x, screen:vertical_offset() + y,
        screen.x + x + boundary_step, screen:vertical_offset() + y
      )
    end
  end
end

---
-- @tparam GameSettings settings
-- @tparam Rectangle screen
-- @tparam PlotGroup plots
function drawing._draw_plots(settings, screen, plots)
  assert(types.is_instance(settings, GameSettings))
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_instance(plots, PlotGroup))

  local iterator = PlotIteratorFactory:new(function(index, point)
    assert(types.is_number_with_limits(index, 1))
    assert(types.is_number_with_limits(point))

    return Point:new(
      screen.x + (index - 1) * settings:step(screen, "plot"),
      screen:vertical_offset() + point * screen:plot_height()
    )
  end)

  local plot_line_width = screen.height / 80
  drawing._draw_plot(
    plots.random,
    iterator,
    Color(0, 0, 0.5, 1),
    plot_line_width
  )
  drawing._draw_plot(
    plots.custom_source,
    iterator,
    Color(0, 0.33, 0, 1),
    plot_line_width / 2
  )
  drawing._draw_plot(
    plots.custom,
    iterator,
    Color(0, 0.66, 0, 1),
    plot_line_width
  )
end

---
-- @tparam Plot plot
-- @tparam PlotIteratorFactory iterator
-- @tparam Color color
-- @tparam int width [0, ∞)
function drawing._draw_plot(plot, iterator, color, width)
  assert(types.is_instance(plot, Plot))
  assert(types.is_instance(iterator, PlotIteratorFactory))
  assert(types.is_instance(color, Color))
  assert(types.is_number_with_limits(width, 0))

  local plot_points = {}
  for _, point in ipairs(iterator:with(plot)) do
    table.insert(plot_points, point.x)
    table.insert(plot_points, point.y)
  end

  love.graphics.setColor(color:channels())
  love.graphics.setLineJoin("bevel")
  love.graphics.setLineWidth(width)
  love.graphics.line(plot_points)
end

---
-- @tparam Rectangle screen
function drawing._draw_pause_background(screen)
  assert(types.is_instance(screen, Rectangle))

  love.graphics.setColor(0, 0, 0, 0.75)
  love.graphics.rectangle(
    "fill",
    screen.x,
    screen.y,
    screen.width,
    screen.height
  )
end

return drawing
