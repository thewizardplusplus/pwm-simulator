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
-- @tparam "fast_inactive_custom"|"inactive_custom"|"active_custom" custom_plot
function PlotGroup:update(settings, custom_plot)
  assertions.is_instance(settings, GameSettings)
  assertions.is_enumeration(custom_plot, {
    "fast_inactive_custom",
    "inactive_custom",
    "active_custom",
  })

  local custom_plot_factor = settings:plot_factor(custom_plot)
  local maximum_factor = math.max(
    math.abs(settings:plot_factor("active_custom")),
    math.abs(settings:plot_factor("inactive_custom")),
    math.abs(settings:plot_factor("fast_inactive_custom"))
  )
  -- Center zero movement at 0.5; screen y increases downward.
  local source_value = 0.5
  if maximum_factor > 0 then
    source_value = 0.5 + custom_plot_factor / (2 * maximum_factor)
  end

  self.random:update(settings:plot_factor("random"))
  self.custom:update(custom_plot_factor)
  self.custom_source:update(source_value)
end

return PlotGroup
