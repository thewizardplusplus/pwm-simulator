---
-- @module ui

local types = require("luaplot.types")
local Color = require("models.color")

local ui = {}

---
-- @tparam number value
-- @tparam int grid_step
-- @treturn int
function ui._get_label_width(value, grid_step)
  assert(types.is_number_with_limits(value, 0, 100))
  assert(types.is_number_with_limits(grid_step, 0))

  local label_width
  if value == 100 then -- three digits
    label_width = 2.76 * grid_step
  elseif value >= 10 then -- two digits
    label_width = 2.4 * grid_step
  else -- one digit
    label_width = 2 * grid_step
  end

  -- rounding to an integer
  return math.floor(label_width + 0.5)
end

---
-- @tparam Color color
-- @tparam "left"|"right" align
-- @treturn tab common SUIT widget options
function ui._create_label_options(color, align)
  assert(types.is_instance(color, Color))
  assert(align == "left" or align == "right")

  return {
    color = {normal = {fg = color:channels()}},
    align = align,
    valign = "top",
  }
end

return ui
