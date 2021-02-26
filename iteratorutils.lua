---
-- @module iteratorutils

local types = require("luaplot.types")
local iterators = require("luaplot.iterators")
local Plot = require("luaplot.plot")

local iteratorutils = {}

---
-- @tparam Plot plot_one
-- @tparam Plot plot_two
-- @tparam number index [1, ∞)
-- @tparam {DistanceLimit,...} cases
-- @treturn any
function iteratorutils.select_case_by_distance(plot_one, plot_two, index, cases)
  assert(types.is_instance(plot_one, Plot))
  assert(types.is_instance(plot_two, Plot))
  assert(types.is_number_with_limits(index, 1))
  assert(type(cases) == "table")

  local suitable_value
  local distance = iterators.difference(plot_one, plot_two, index, true)
  for _, case in ipairs(cases) do
    if distance < case.limit then
      suitable_value = case.suitable_value
      break
    end
  end

  return suitable_value
end

return iteratorutils
