---
-- @module ui

local suit = require("suit")
local types = require("luaplot.types")
local Stats = require("models.stats")
local Color = require("models.color")
local Rectangle = require("models.rectangle")
local UiUpdate = require("models.uiupdate")
local colors = require("constants.colors")

local ui = {}

---
-- @tparam Rectangle screen
function ui.draw(screen)
  assert(types.is_instance(screen, Rectangle))

  local font_size = screen.height / 20
  love.graphics.setFont(love.graphics.newFont(font_size))

  suit.draw()
end

-- @tparam Rectangle screen
-- @tparam int plot_height
-- @tparam Stats normal_stats
-- @tparam Stats best_stats
-- @tparam bool pause
-- @treturn UiUpdate
function ui.update(screen, plot_height, normal_stats, best_stats, pause)
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_number_with_limits(plot_height, 0))
  assert(types.is_instance(normal_stats, Stats))
  assert(types.is_instance(best_stats, Stats))
  assert(type(pause) == "boolean")

  local grid_step = screen.height / 12
  ui._update_labels(screen, grid_step, plot_height, normal_stats, best_stats)
  return ui._update_buttons(screen, grid_step, pause)
end

---
-- @tparam Rectangle screen
-- @tparam int grid_step
-- @tparam int plot_height
-- @tparam Stats normal_stats
-- @tparam Stats best_stats
function ui._update_labels(
  screen,
  grid_step,
  plot_height,
  normal_stats,
  best_stats
)
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_number_with_limits(grid_step, 0))
  assert(types.is_number_with_limits(plot_height, 0))
  assert(types.is_instance(normal_stats, Stats))
  assert(types.is_instance(best_stats, Stats))

  local vertical_offset = screen.y + (screen.height - plot_height) / 2

  ui._update_label_row("Best:", best_stats, ui._create_label_layout(
    screen.x + grid_step / 2,
    vertical_offset - 1.75 * grid_step,
    grid_step,
    normal_stats,
    best_stats
  ))

  ui._update_label_row("Now:", normal_stats, ui._create_label_layout(
    screen.x + grid_step / 2,
    vertical_offset - grid_step,
    grid_step,
    normal_stats,
    best_stats
  ))
end

---
-- @tparam string title
-- @tparam Stats stats
-- @tparam tab label_layout SUIT precomputed layout
function ui._update_label_row(title, stats, label_layout)
  assert(type(title) == "string")
  assert(types.is_instance(stats, Stats))
  assert(type(label_layout) == "table")

  suit.Label(
    title,
    ui._create_label_options(Color:new(0.5, 0.5, 0.5, 1), "left"),
    label_layout:cell(1)
  )

  suit.Label(
    "#",
    ui._create_label_options(colors.NORMAL_DISTANCE_COLOR, "left"),
    label_layout:cell(3)
  )
  suit.Label(
    string.format("%.2f%%", stats:percentage("normal")),
    ui._create_label_options(Color:new(0.5, 0.5, 0.5, 1), "right"),
    label_layout:cell(4)
  )

  suit.Label(
    "#",
    ui._create_label_options(colors.SOFT_DISTANCE_LIMIT_COLOR, "left"),
    label_layout:cell(6)
  )
  suit.Label(
    string.format("%.2f%%", stats:percentage("soft_limit")),
    ui._create_label_options(Color:new(0.5, 0.5, 0.5, 1), "right"),
    label_layout:cell(7)
  )

  suit.Label(
    "#",
    ui._create_label_options(colors.HARD_DISTANCE_LIMIT_COLOR, "left"),
    label_layout:cell(9)
  )
  suit.Label(
    string.format("%.2f%%", stats:percentage("hard_limit")),
    ui._create_label_options(Color:new(0.5, 0.5, 0.5, 1), "right"),
    label_layout:cell(10)
  )
end

---
-- @tparam Rectangle screen
-- @tparam int grid_step
-- @tparam bool pause
-- @treturn UiUpdate
function ui._update_buttons(screen, grid_step, pause)
  assert(types.is_instance(screen, Rectangle))
  assert(types.is_number_with_limits(grid_step, 0))
  assert(type(pause) == "boolean")

  suit.layout:reset(
    screen.x + screen.width - 1.25 * grid_step,
    screen.y + 0.25 * grid_step
  )

  local pause_button_text = pause and "|>" or "||"
  local pause_button = suit.Button(
    pause_button_text,
    suit.layout:row(grid_step, grid_step)
  )
  return UiUpdate:new(pause_button.hit)
end

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
