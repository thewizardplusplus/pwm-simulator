---
-- @classmod PlotGroup

local middleclass = require("middleclass")
local types = require("luaplot.types")
local GameSettings = require("models.gamesettings")
local Oscillogram = require("luaplot.oscillogram")

local PlotGroup = middleclass("PlotGroup")

---
-- @table instance
-- @tfield Oscillogram random
-- @tfield Oscillogram custom
-- @tfield Oscillogram custom_source

---
-- @function new
-- @tparam GameSettings settings
-- @treturn PlotGroup
function PlotGroup:initialize(settings)
  assert(types.is_instance(settings, GameSettings))

  self.random = Oscillogram:new("random", settings:plot_length("random"), 0.5)
  self.custom = Oscillogram:new("linear", settings:plot_length("custom"), 0.5)
  self.custom_source =
    Oscillogram:new("custom", settings:plot_length("custom"), 0.5)
end

return PlotGroup
