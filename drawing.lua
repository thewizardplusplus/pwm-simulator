---
-- @module drawing

local types = require("luaplot.types")
local Plot = require("luaplot.plot")
local PlotIteratorFactory = require("luaplot.plotiteratorfactory")
local Color = require("models.color")
local Rectangle = require("models.rectangle")

local drawing = {}

---
-- @tparam Rectangle screen
-- @tparam int plot_height
-- @tparam int plot_step
-- @tparam Plot random_plot
-- @tparam Plot custom_source_plot
-- @tparam Plot custom_plot
function drawing._draw_plots(
  screen,
  plot_height,
  plot_step,
  random_plot,
  custom_source_plot,
  custom_plot
)
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_number_with_limits(plot_height, 0))
  assert(types.is_number_with_limits(plot_step, 0))
  assert(types.is_instance(random_plot, Plot))
  assert(types.is_instance(custom_source_plot, Plot))
  assert(types.is_instance(custom_plot, Plot))

  local vertical_offset = screen.y + (screen.height - plot_height) / 2
  local iterator = PlotIteratorFactory:new(function(index, point)
    assert(types.is_number_with_limits(index, 1))
    assert(types.is_number_with_limits(point))

    return {
      x = screen.x + (index - 1) * plot_step,
      y = vertical_offset + point * plot_height,
    }
  end)

  local plot_line_width = screen.height / 80
  drawing._draw_plot(
    random_plot,
    iterator,
    Color(0, 0, 0.5, 1),
    plot_line_width
  )
  drawing._draw_plot(
    custom_source_plot,
    iterator,
    Color(0, 0.33, 0, 1),
    plot_line_width / 2
  )
  drawing._draw_plot(
    custom_plot,
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
