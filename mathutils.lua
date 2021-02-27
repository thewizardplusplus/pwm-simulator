---
-- @module mathutils

local types = require("luaplot.types")

local mathutils = {}

---
-- @tparam number value
-- @treturn int
function mathutils.round_positive(value)
  assert(types.is_number_with_limits(value, 0))

  return math.floor(value + 0.5)
end

return mathutils
