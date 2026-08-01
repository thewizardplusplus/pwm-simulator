---
-- @module icons

local utf8 = require("utf8")

local icons = {}

---
-- @table icons
-- @tfield string PLAY_ICON
-- @tfield string PAUSE_ICON

icons.PLAY_ICON = utf8.char(0xf04b)
icons.PAUSE_ICON = utf8.char(0xf04c)

return icons
