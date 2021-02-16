---
-- @module ui

local suit = require("suit")
local types = require("luaplot.types")
local Stats = require("models.stats")
local Color = require("models.color")

local ui = {}

---
-- @tparam int x
-- @tparam int y
-- @tparam int grid_step
-- @tparam Stats normal_stats
-- @tparam Stats best_stats
-- @treturn tab SUIT precomputed layout
function ui._create_label_layout(x, y, grid_step, normal_stats, best_stats)
  assert(types.is_number_with_limits(x, 0))
  assert(types.is_number_with_limits(y, 0))
  assert(types.is_number_with_limits(grid_step, 0))
  assert(types.is_instance(normal_stats, Stats))
  assert(types.is_instance(best_stats, Stats))

  local maximal_normal_result = math.max(
    normal_stats:percentage("normal"),
    best_stats:percentage("normal")
  )
  local normal_label_width =
    ui._get_label_width(maximal_normal_result, grid_step)

  local maximal_soft_limit_result = math.max(
    normal_stats:percentage("soft_limit"),
    best_stats:percentage("soft_limit")
  )
  local soft_limit_label_width =
    ui._get_label_width(maximal_soft_limit_result, grid_step)

  local maximal_hard_limit_result = math.max(
    normal_stats:percentage("hard_limit"),
    best_stats:percentage("hard_limit")
  )
  local hard_limit_label_width =
    ui._get_label_width(maximal_hard_limit_result, grid_step)

  local padding = grid_step / 2
  return suit.layout:cols({
    pos = {x, y},

    {1.7 * grid_step, grid_step},
    {padding, nil},

    {0.75 * grid_step, nil},
    {normal_label_width, nil},
    {padding, nil},

    {0.75 * grid_step, nil},
    {soft_limit_label_width, nil},
    {padding, nil},

    {0.75 * grid_step, nil},
    {hard_limit_label_width, nil},
  })
end

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
