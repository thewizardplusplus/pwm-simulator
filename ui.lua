---
-- @module ui

local suit = require("suit")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local colors = require("constants.colors")
local icons = require("constants.icons")
local Stats = require("models.stats")
local StatsGroup = require("models.statsgroup")
local Color = require("models.color")
local Rectangle = require("models.rectangle")
local UiUpdate = require("models.uiupdate")

local _ICONS_FONT_PATH =
  "resources/fonts/font-awesome/font_awesome_free_7.3.0_solid_900.otf"

local ui = {}

---
-- @tparam Rectangle screen
-- @treturn {[string]=Font,...}
function ui.load_fonts(screen)
  assertions.is_instance(screen, Rectangle)

  local font_size = screen.height / 20
  return {
    default = love.graphics.newFont(font_size),
    icons = love.graphics.newFont(_ICONS_FONT_PATH, font_size),
  }
end

---
-- @function draw
function ui.draw()
  suit.draw()
end

---
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
-- @tparam StatsGroup stats
-- @tparam bool pause
-- @treturn UiUpdate
function ui.update(screen, fonts, stats, pause)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_instance(stats, StatsGroup)
  assertions.is_boolean(pause)

  local grid_step = math.floor(screen.height / 12)
  ui._update_labels(screen, fonts, grid_step, stats)
  return ui._update_buttons(screen, fonts, grid_step, pause)
end

---
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
-- @tparam int grid_step [0, ∞)
-- @tparam StatsGroup stats
function ui._update_labels(screen, fonts, grid_step, stats)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_integer(grid_step)
  assertions.is_instance(stats, StatsGroup)

  ui._update_label_row(fonts, "Best:", stats.best, ui._create_label_layout(
    math.floor(screen.x + grid_step / 2),
    math.floor(screen:vertical_offset() - 1.75 * grid_step),
    grid_step,
    stats
  ))

  ui._update_label_row(fonts, "Now:", stats.current, ui._create_label_layout(
    math.floor(screen.x + grid_step / 2),
    math.floor(screen:vertical_offset() - grid_step),
    grid_step,
    stats
  ))
end

---
-- @tparam {[string]=Font,...} fonts
-- @tparam string title
-- @tparam Stats stats
-- @tparam tab label_layout SUIT precomputed layout
function ui._update_label_row(fonts, title, stats, label_layout)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_string(title)
  assertions.is_instance(stats, Stats)
  assertions.is_table(label_layout)

  suit.Label(
    title,
    ui._create_label_options(
      fonts.default,
      "left",
      Color:new(0.5, 0.5, 0.5, 1)
    ),
    label_layout:cell(1)
  )

  suit.Label(
    "#",
    ui._create_label_options(
      fonts.default,
      "left",
      colors.NORMAL_DISTANCE_COLOR
    ),
    label_layout:cell(3)
  )
  suit.Label(
    string.format("%.2f%%", stats:percentage("normal")),
    ui._create_label_options(
      fonts.default,
      "right",
      Color:new(0.5, 0.5, 0.5, 1)
    ),
    label_layout:cell(4)
  )

  suit.Label(
    "#",
    ui._create_label_options(
      fonts.default,
      "left",
      colors.SOFT_DISTANCE_LIMIT_COLOR
    ),
    label_layout:cell(6)
  )
  suit.Label(
    string.format("%.2f%%", stats:percentage("soft_limit")),
    ui._create_label_options(
      fonts.default,
      "right",
      Color:new(0.5, 0.5, 0.5, 1)
    ),
    label_layout:cell(7)
  )

  suit.Label(
    "#",
    ui._create_label_options(
      fonts.default,
      "left",
      colors.HARD_DISTANCE_LIMIT_COLOR
    ),
    label_layout:cell(9)
  )
  suit.Label(
    string.format("%.2f%%", stats:percentage("hard_limit")),
    ui._create_label_options(
      fonts.default,
      "right",
      Color:new(0.5, 0.5, 0.5, 1)
    ),
    label_layout:cell(10)
  )
end

---
-- @tparam Rectangle screen
-- @tparam {[string]=Font,...} fonts
-- @tparam int grid_step [0, ∞)
-- @tparam bool pause
-- @treturn UiUpdate
function ui._update_buttons(screen, fonts, grid_step, pause)
  assertions.is_instance(screen, Rectangle)
  assertions.is_table(fonts, checks.is_string, function(font)
    return type(font) == "userdata"
  end)
  assertions.is_integer(grid_step)
  assertions.is_boolean(pause)

  suit.layout:reset(
    screen.x + screen.width - 1.5 * grid_step,
    screen:vertical_offset() - 1.5 * grid_step
  )

  local pause_button = suit.Button(
    pause and icons.PLAY_ICON or icons.PAUSE_ICON,
    { font = fonts.icons },
    suit.layout:row(grid_step, grid_step)
  )
  return UiUpdate:new(pause_button.hit)
end

---
-- @tparam int x [0, ∞)
-- @tparam int y [0, ∞)
-- @tparam int grid_step [0, ∞)
-- @tparam StatsGroup stats
-- @treturn tab SUIT precomputed layout
function ui._create_label_layout(x, y, grid_step, stats)
  assertions.is_integer(x)
  assertions.is_integer(y)
  assertions.is_integer(grid_step)
  assertions.is_instance(stats, StatsGroup)

  local normal_label_width =
    ui._get_label_width(stats:max_percentage("normal"), grid_step)
  local soft_limit_label_width =
    ui._get_label_width(stats:max_percentage("soft_limit"), grid_step)
  local hard_limit_label_width =
    ui._get_label_width(stats:max_percentage("hard_limit"), grid_step)

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
-- @tparam number value [0, 100]
-- @tparam int grid_step [0, ∞)
-- @treturn number
function ui._get_label_width(value, grid_step)
  assertions.is_number(value)
  assertions.is_integer(grid_step)

  local label_width
  if value == 100 then -- three digits
    label_width = 2.9 * grid_step
  elseif value >= 10 then -- two digits
    label_width = 2.5 * grid_step
  else -- one digit
    label_width = 2.1 * grid_step
  end

  return label_width
end

---
-- @tparam Font font
-- @tparam "left"|"right" align
-- @tparam Color color
-- @treturn tab common SUIT widget options
function ui._create_label_options(font, align, color)
  assertions.is_true(type(font) == "userdata")
  assertions.is_enumeration(align, {"left", "right"})
  assertions.is_instance(color, Color)

  return {
    font = font,
    align = align,
    valign = "top",
    color = { normal = { fg = color:channels() } },
  }
end

return ui
