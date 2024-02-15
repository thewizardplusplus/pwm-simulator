---
-- @classmod PlotGroup

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
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
  assertions.is_instance(settings, GameSettings)

  self.random = Oscillogram:new("random", settings:plot_length("random"), 0.5)
  self.custom = Oscillogram:new("linear", settings:plot_length("custom"), 0.5)
  self.custom_source =
    Oscillogram:new("custom", settings:plot_length("custom"), 0.5)
end

---
-- @tparam GameSettings settings
-- @tparam bool custom_plot_activity
function PlotGroup:update(settings, custom_plot_activity)
  assertions.is_instance(settings, GameSettings)
  assertions.is_boolean(custom_plot_activity)

  local custom_plot =
    custom_plot_activity and "active_custom" or "inactive_custom"
  self.random:update(settings:plot_factor("random"))
  self.custom:update(settings:plot_factor(custom_plot))
  self.custom_source:update(custom_plot_activity and 0 or 1)
end

return PlotGroup
