-- luacheck: no max comment line length

---
-- @classmod Rectangle

local middleclass = require("middleclass")
local assertions = require("luatypechecks.assertions")
local checks = require("luatypechecks.checks")
local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")
local Range = require("luamath.models.range")
local BoundingBox = require("luamath.models.boundingbox")

local Rectangle = middleclass("Rectangle", BoundingBox)

---
-- @function schema
-- @static
-- @treturn tab JSON Schema for this class
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)

---
-- @function from_options
-- @static
-- @tparam tab options constructor options conforming to the JSON Schema
--   returned by @{Rectangle.schema|Rectangle.schema()}
--   (see the [luaserialization](https://github.com/thewizardplusplus/luaserialization) library)
-- @treturn Rectangle
function Rectangle.static.from_options(options)
  assertions.is_table(options)

  local result = BoundingBox.from_options(options)
  return Rectangle:new(result.min, result.max)
end

---
-- @function from_position_and_size
-- @static
-- @tparam Vector2D position
-- @tparam Size size
-- @treturn Rectangle
-- @raise error message
function Rectangle.static.from_position_and_size(position, size)
  assertions.is_instance(position, Vector2D)
  assertions.is_instance(size, Size)

  local result = BoundingBox.from_position_and_size(position, size)
  return Rectangle:new(result.min, result.max)
end

---
-- @function from_ranges
-- @static
-- @tparam Range x_range horizontal range
-- @tparam Range y_range vertical range
-- @treturn Rectangle
function Rectangle.static.from_ranges(x_range, y_range)
  assertions.is_instance(x_range, Range)
  assertions.is_instance(y_range, Range)

  local result = BoundingBox.from_ranges(x_range, y_range)
  return Rectangle:new(result.min, result.max)
end

---
-- @function union
-- @static
-- @tparam BoundingBox,... ... one or more boxes
-- @treturn Rectangle the smallest box containing all input boxes
-- @raise error message
function Rectangle.static.union(...)
  assertions.is_sequence({...}, checks.make_instance_checker(BoundingBox))

  local result = BoundingBox.union(...)
  return Rectangle:new(result.min, result.max)
end

---
-- @function intersection
-- @static
-- @tparam BoundingBox,... ... one or more boxes
-- @treturn Rectangle|nil the common closed region of all input boxes, or nil if empty
--   boxes touching at an edge or corner produce a degenerate box
-- @raise error message
function Rectangle.static.intersection(...)
  assertions.is_sequence({...}, checks.make_instance_checker(BoundingBox))

  local result = BoundingBox.intersection(...)
  if result == nil then
    return nil
  end

  return Rectangle:new(result.min, result.max)
end

---
-- @table instance
-- @tfield Vector2D min top-left corner
-- @tfield Vector2D max bottom-right corner

---
-- @function new
-- @tparam Vector2D min top-left corner
-- @tparam Vector2D max bottom-right corner
-- @treturn Rectangle
-- @raise error message

---
-- @function __data
-- @treturn table table with instance fields

---
-- @function __tostring
-- @treturn string stringified table with instance fields

---
-- @function equals
-- @tparam BoundingBox other
-- @treturn boolean

---
-- @function __eq
-- @tparam BoundingBox left_operand
-- @tparam BoundingBox right_operand
-- @treturn boolean

---
-- @function almost_equals
-- @tparam BoundingBox other
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean

---
-- @function is_valid
-- @treturn boolean whether `min` is at most `max` on each axis

---
-- @function is_degenerate
-- @tparam[opt] "x"|"y" axis axis to check;
--   when omitted, checks whether either axis is degenerate
-- @treturn boolean whether the selected axis, or either axis, has zero length
-- @raise error message

---
-- @function is_almost_degenerate
-- @tparam[opt=1e-6] number epsilon
-- @tparam[optchain] "x"|"y" axis axis to check;
--   when omitted, checks whether either axis is almost degenerate
-- @treturn boolean whether the selected axis, or either axis, has almost zero length
-- @raise error message

---
-- @function is_point
-- @treturn boolean whether the box is degenerate on both axes

---
-- @function is_almost_point
-- @tparam[opt=1e-6] number epsilon
-- @treturn boolean whether the box is almost degenerate on both axes

---
-- @function position
-- @treturn Vector2D alias for `min`

---
-- @function size
-- @treturn Size width and height of the box

---
-- @function x_range
-- @treturn Range horizontal range

---
-- @function y_range
-- @treturn Range vertical range

---
-- @function center
-- @treturn Vector2D center of the box

---
-- @function top_left
-- @treturn Vector2D top-left corner; alias for `min`

---
-- @function top_right
-- @treturn Vector2D top-right corner

---
-- @function bottom_left
-- @treturn Vector2D bottom-left corner

---
-- @function bottom_right
-- @treturn Vector2D bottom-right corner; alias for `max`

---
-- @function overlaps
-- @tparam BoundingBox other
-- @treturn boolean whether the intersection has positive area; contact only at
--   edges or corners does not count

---
-- @function contains
-- @tparam Vector2D|BoundingBox value
-- @treturn boolean whether the closed box contains the value;
--   points and box boundaries are included

---
-- @function clamp
-- @tparam Vector2D value
-- @treturn Vector2D value clamped independently on each axis

---
-- @function lerp
-- @tparam Vector2D progress per-axis interpolation progress
-- @treturn Vector2D

---
-- @function inverse_lerp
-- @tparam Vector2D value
-- @treturn Vector2D per-axis interpolation progress
-- @raise error message if either axis is degenerate

---
-- @function wrap
-- @tparam Vector2D value
-- @treturn Vector2D value wrapped independently into the half-open intervals
--   `[min.x, max.x)` and `[min.y, max.y)`
-- @raise error message if either axis is degenerate

---
-- @function random
-- @treturn Vector2D random value in the half-open intervals
--   `[min.x, max.x)` and `[min.y, max.y)`
-- @raise error message if either axis is degenerate

---
-- @tparam Vector2D delta
-- @treturn Rectangle
function Rectangle:translate(delta)
  assertions.is_instance(delta, Vector2D)

  local result = BoundingBox.translate(self, delta)
  return Rectangle:new(result.min, result.max)
end

---
-- @tparam BoundingBox left_operand
-- @tparam Vector2D right_operand
-- @treturn Rectangle
function Rectangle.__add(left_operand, right_operand)
  assertions.is_instance(left_operand, BoundingBox)
  assertions.is_instance(right_operand, Vector2D)

  local result = BoundingBox.__add(left_operand, right_operand)
  return Rectangle:new(result.min, result.max)
end

---
-- @tparam BoundingBox left_operand
-- @tparam Vector2D right_operand
-- @treturn Rectangle
function Rectangle.__sub(left_operand, right_operand)
  assertions.is_instance(left_operand, BoundingBox)
  assertions.is_instance(right_operand, Vector2D)

  local result = BoundingBox.__sub(left_operand, right_operand)
  return Rectangle:new(result.min, result.max)
end

---
-- ⚠️. Expand the box symmetrically by per-axis amounts.
-- @tparam number|Vector2D delta uniform or per-axis amount
-- @treturn Rectangle
-- @raise error message
function Rectangle:expand(delta)
  local is_delta_number = checks.is_number(delta)
  local is_delta_vector_2d = checks.is_instance(delta, Vector2D)
  assertions.is_true(is_delta_number or is_delta_vector_2d)

  local result = BoundingBox.expand(self, delta)
  return Rectangle:new(result.min, result.max)
end

---
-- ⚠️. Scale the box around its center by per-axis factors.
-- @tparam number|Vector2D scale non-negative uniform or per-axis scale
-- @treturn Rectangle
-- @raise error message
function Rectangle:scale(scale)
  local is_scale_number = checks.is_number(scale)
  local is_scale_vector_2d = checks.is_instance(scale, Vector2D)
  assertions.is_true(is_scale_number or is_scale_vector_2d)

  local result = BoundingBox.scale(self, scale)
  return Rectangle:new(result.min, result.max)
end

---
-- @treturn Rectangle centered area occupied by plots
function Rectangle:plot_area()
  return self:scale(Vector2D:new(1, 2 / 3))
end

return Rectangle
