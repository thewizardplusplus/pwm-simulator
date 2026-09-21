---
-- @module colors

local Color = require("luamath.models.color")

local colors = {}

---
-- @table colors
-- @tfield Color NORMAL_DISTANCE_COLOR
-- @tfield Color SOFT_DISTANCE_LIMIT_COLOR
-- @tfield Color HARD_DISTANCE_LIMIT_COLOR

colors.NORMAL_DISTANCE_COLOR = Color.GREEN:with_alpha(0.25)
colors.SOFT_DISTANCE_LIMIT_COLOR = Color:new(1, 1, 0, 0.25)
colors.HARD_DISTANCE_LIMIT_COLOR = Color.RED:with_alpha(0.25)

return colors
