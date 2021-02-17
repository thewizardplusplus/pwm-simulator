---
-- @module colors

local Color = require("models.color")

local colors = {}

---
-- @table colors
-- @tfield Color NORMAL_DISTANCE_COLOR
-- @tfield Color SOFT_DISTANCE_LIMIT_COLOR
-- @tfield Color HARD_DISTANCE_LIMIT_COLOR

colors.NORMAL_DISTANCE_COLOR = Color:new(0, 1, 0, 0.25)
colors.SOFT_DISTANCE_LIMIT_COLOR = Color:new(1, 1, 0, 0.25)
colors.HARD_DISTANCE_LIMIT_COLOR = Color:new(1, 0, 0, 0.25)

return colors
