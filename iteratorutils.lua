---
-- @module iteratorutils

local types = require("luaplot.types")
local iterators = require("luaplot.iterators")
local PlotGroup = require("models.plotgroup")

local iteratorutils = {}

---
-- @tparam PlotGroup plots
-- @tparam number index [1, ∞)
-- @tparam {DistanceLimit,...} cases
-- @treturn any
function iteratorutils.select_case_by_distance(plots, index, cases)
  assert(types.is_instance(plots, PlotGroup))
  assert(types.is_number_with_limits(index, 1))
  assert(type(cases) == "table")

  local suitable_value
  local distance = iterators.difference(plots.random, plots.custom, index, true)
  for _, case in ipairs(cases) do
    if distance < case.limit then
      suitable_value = case.suitable_value
      break
    end
  end

  return suitable_value
end

return iteratorutils
