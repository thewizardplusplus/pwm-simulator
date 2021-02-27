---
-- @module drawing

local types = require("luaplot.types")
local iteratorutils = require("iteratorutils")
local Plot = require("luaplot.plot")
local PlotIteratorFactory = require("luaplot.plotiteratorfactory")
local PlotGroup = require("models.plotgroup")
local Color = require("models.color")
local Rectangle = require("models.rectangle")
local Point = require("models.point")

local drawing = {}

---
-- @tparam Rectangle screen
-- @tparam int plot_height
-- @tparam int plot_step
-- @tparam int sampling_rate
-- @tparam PlotGroup plots
-- @tparam bool pause
-- @tparam {DistanceLimit,...} cases
function drawing.draw_game(
  screen,
  plot_height,
  plot_step,
  sampling_rate,
  plots,
  pause,
  cases
)
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_number_with_limits(plot_height, 0))
  assert(types.is_number_with_limits(plot_step, 0))
  assert(types.is_number_with_limits(sampling_rate, 0))
  assert(types.is_instance(plots, PlotGroup))
  assert(type(pause) == "boolean")
  assert(type(cases) == "table")

  drawing._draw_distance(
    screen,
    plot_height,
    plot_step,
    sampling_rate,
    plots,
    cases
  )
  drawing._draw_boundaries(screen, plot_height)
  drawing._draw_plots(screen, plot_height, plot_step, plots)
  if pause then
    drawing._draw_pause_background(screen)
  end
end

---
-- @tparam Rectangle screen
-- @tparam int plot_height
-- @tparam int plot_step
-- @tparam int sampling_rate
-- @tparam PlotGroup plots
-- @tparam {DistanceLimit,...} cases
function drawing._draw_distance(
  screen,
  plot_height,
  plot_step,
  sampling_rate,
  plots,
  cases
)
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_number_with_limits(plot_height, 0))
  assert(types.is_number_with_limits(plot_step, 0))
  assert(types.is_number_with_limits(sampling_rate, 0))
  assert(types.is_instance(plots, PlotGroup))
  assert(type(cases) == "table")

  local x = 0
  local sampling_step = (screen.width / 2) / sampling_rate
  for _ = 1, sampling_rate do
    x = x + sampling_step

    local index = x / plot_step + 1
    local suitable_color =
      iteratorutils.select_case_by_distance(plots, index, cases)
    love.graphics.setColor(suitable_color:channels())

    love.graphics.rectangle(
      "fill",
      screen.x + x - sampling_step, screen:vertical_offset(plot_height),
      sampling_step, plot_height
    )
  end
end

---
-- @tparam Rectangle screen
-- @tparam int plot_height
function drawing._draw_boundaries(screen, plot_height)
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_number_with_limits(plot_height, 0))

  local boundary_line_width = screen.height / 320
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.setLineWidth(boundary_line_width)

  local boundary_step = screen.width / 40
  for x = 0, screen.width, 1.5 * boundary_step do
    for _, y in ipairs({0, plot_height}) do
      love.graphics.line(
        screen.x + x, screen:vertical_offset(plot_height) + y,
        screen.x + x + boundary_step, screen:vertical_offset(plot_height) + y
      )
    end
  end
end

---
-- @tparam Rectangle screen
-- @tparam int plot_height
-- @tparam int plot_step
-- @tparam PlotGroup plots
function drawing._draw_plots(screen, plot_height, plot_step, plots)
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_number_with_limits(plot_height, 0))
  assert(types.is_number_with_limits(plot_step, 0))
  assert(types.is_instance(plots, PlotGroup))

  local iterator = PlotIteratorFactory:new(function(index, point)
    assert(types.is_number_with_limits(index, 1))
    assert(types.is_number_with_limits(point))

    return Point:new(
      screen.x + (index - 1) * plot_step,
      screen:vertical_offset(plot_height) + point * plot_height
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
-- @tparam int width
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
