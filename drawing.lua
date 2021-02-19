---
-- @module drawing

local types = require("luaplot.types")
local Plot = require("luaplot.plot")
local PlotIteratorFactory = require("luaplot.plotiteratorfactory")
local Color = require("models.color")
local Rectangle = require("models.rectangle")

local drawing = {}

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
