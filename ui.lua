---
-- @module ui

local types = require("luaplot.types")
local Color = require("models.color")

local ui = {}

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
