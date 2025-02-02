-- luacheck: no max comment line length

---
-- @classmod PlotGroup

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local Nameable = require("luaserialization.nameable")
local Stringifiable = require("luaserialization.stringifiable")
local GameSettings = require("models.gamesettings")
local Oscillogram = require("luaplot.oscillogram")

local PlotGroup = middleclass("PlotGroup")
PlotGroup:include(Nameable)
PlotGroup:include(Stringifiable)

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
-- @treturn tab table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
function PlotGroup:__data()
  return {
    random = self.random,
    custom = self.custom,
    custom_source = self.custom_source,
  }
end

---
-- @function __tostring
-- @treturn string stringified table with instance fields
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

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
