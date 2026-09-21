---
-- @module drawing

local assertions = require("luatypechecks.assertions")
local iterators = require("luaplot.iterators")
local colors = require("constants.colors")
local Vector2D = require("luamath.vector2d")
local Matrix3x3 = require("luamath.matrix3x3")
local Size = require("luamath.models.size")
local BoundingBox = require("luamath.models.boundingbox")
local Color = require("luamath.models.color")
local Plot = require("luaplot.plot")
local PlotIteratorFactory = require("luaplot.plotiteratorfactory")
local DistanceLimit = require("luaplot.distancelimit")
local PlotGroup = require("models.plotgroup")
local Rectangle = require("models.rectangle")
local GameSettings = require("models.gamesettings")
setfenv(1, require("compat53.module"))

local drawing = {}

---
-- @tparam GameSettings settings
-- @tparam Rectangle screen
-- @tparam PlotGroup plots
-- @tparam bool pause
function drawing.draw_game(settings, screen, plots, pause)
  assertions.is_instance(settings, GameSettings)
  assertions.is_instance(screen, Rectangle)
  assertions.is_instance(plots, PlotGroup)
  assertions.is_boolean(pause)

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
  assertions.is_instance(settings, GameSettings)
  assertions.is_instance(screen, Rectangle)
  assertions.is_instance(plots, PlotGroup)

  local plot_area = screen:plot_area()
  local plot_step, distance_step =
    settings:step(screen, "plot"), settings:step(screen, "distance")
  local offset = Vector2D:new(0, 0)
  for _ = 1, settings.distance_sampling_rate do
    offset = offset + Vector2D:new(distance_step, 0)

    local index = math.floor(offset.x / plot_step + 1)
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

    drawing._draw_rectangle("fill", BoundingBox.from_position_and_size(
      plot_area.min + offset - Vector2D:new(distance_step, 0),
      Size:new(distance_step, plot_area:size().height)
    ))
  end
end

---
-- @tparam Rectangle screen
function drawing._draw_boundaries(screen)
  assertions.is_instance(screen, Rectangle)

  local screen_size = screen:size()
  local boundary_line_width = screen_size.height / 320
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.setLineWidth(boundary_line_width)

  local boundary_step = screen_size.width / 40
  local plot_area = screen:plot_area()
  for x = 0, screen_size.width, 1.5 * boundary_step do
    for _, y in ipairs({plot_area.min.y, plot_area.max.y}) do
      local start = Vector2D:new(plot_area.min.x + x, y)
      local finish = start + Vector2D:new(boundary_step, 0)
      love.graphics.line(start.x, start.y, finish.x, finish.y)
    end
  end
end

---
-- @tparam GameSettings settings
-- @tparam Rectangle screen
-- @tparam PlotGroup plots
function drawing._draw_plots(settings, screen, plots)
  assertions.is_instance(settings, GameSettings)
  assertions.is_instance(screen, Rectangle)
  assertions.is_instance(plots, PlotGroup)

  local plot_area = screen:plot_area()
  local plot_step = settings:step(screen, "plot")
  local transform =
    Matrix3x3.translate(plot_area.min - Vector2D:new(plot_step, 0))
    * Matrix3x3.scale(Vector2D:new(plot_step, plot_area:size().height))
  local iterator = PlotIteratorFactory:new(function(point)
    assertions.is_instance(point, Vector2D)

    return point * transform
  end)

  local plot_line_width = math.floor(screen:size().height / 80)
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
    math.floor(plot_line_width / 2)
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
  assertions.is_instance(plot, Plot)
  assertions.is_instance(iterator, PlotIteratorFactory)
  assertions.is_instance(color, Color)
  assertions.is_integer(width)

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
-- @tparam BoundingBox screen
function drawing._draw_pause_background(screen)
  assertions.is_instance(screen, BoundingBox)

  love.graphics.setColor(Color.BLACK:with_alpha(0.75):channels())
  drawing._draw_rectangle("fill", screen)
end

---
-- @tparam "fill"|"line" mode
-- @tparam BoundingBox rectangle
function drawing._draw_rectangle(mode, rectangle)
  assertions.is_enumeration(mode, {"fill", "line"})
  assertions.is_instance(rectangle, BoundingBox)

  local position = rectangle:position()
  local size = rectangle:size()
  love.graphics.rectangle(
    mode,
    position.x,
    position.y,
    size.width,
    size.height
  )
end

return drawing
