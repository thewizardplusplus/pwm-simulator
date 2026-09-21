local luaunit = require("luaunit")
local checks = require("luatypechecks.checks")
local Vector2D = require("luamath.vector2d")
local Size = require("luamath.models.size")
local Range = require("luamath.models.range")
local Rectangle = require("models.rectangle")

-- luacheck: globals TestRectangle
TestRectangle = {}

function TestRectangle.test_from_options()
  local result = Rectangle.from_options({
    min = Vector2D:new(10, 20),
    max = Vector2D:new(40, 60),
  })

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(10, 20),
    Vector2D:new(40, 60)
  ))
end

function TestRectangle.test_from_position_and_size()
  local result = Rectangle.from_position_and_size(
    Vector2D:new(10, 20),
    Size:new(30, 40)
  )

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(10, 20),
    Vector2D:new(40, 60)
  ))
end

function TestRectangle.test_from_ranges()
  local result = Rectangle.from_ranges(Range:new(10, 40), Range:new(20, 60))

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(10, 20),
    Vector2D:new(40, 60)
  ))
end

function TestRectangle.test_union()
  local result = Rectangle.union(
    Rectangle:new(Vector2D:new(10, 20), Vector2D:new(30, 50)),
    Rectangle:new(Vector2D:new(20, 10), Vector2D:new(40, 60))
  )

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(10, 10),
    Vector2D:new(40, 60)
  ))
end

function TestRectangle.test_intersection_multiple_values()
  local result = Rectangle.intersection(
    Rectangle:new(Vector2D:new(10, 20), Vector2D:new(30, 50)),
    Rectangle:new(Vector2D:new(20, 10), Vector2D:new(40, 60))
  )

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(20, 20),
    Vector2D:new(30, 50)
  ))
end

function TestRectangle.test_intersection_no_overlap()
  local result = Rectangle.intersection(
    Rectangle:new(Vector2D:new(0, 0), Vector2D:new(1, 1)),
    Rectangle:new(Vector2D:new(2, 2), Vector2D:new(3, 3))
  )

  luaunit.assert_is_nil(result)
end

function TestRectangle.test_tostring()
  local rectangle = Rectangle:new(Vector2D:new(10, 20), Vector2D:new(40, 60))
  local text = tostring(rectangle)

  luaunit.assert_is_string(text)
  luaunit.assert_equals(text, "{" ..
    "__name = \"Rectangle\"," ..
    "max = {" ..
      "__name = \"Vector2D\"," ..
      "x = 40," ..
      "y = 60" ..
    "}," ..
    "min = {" ..
      "__name = \"Vector2D\"," ..
      "x = 10," ..
      "y = 20" ..
    "}" ..
  "}")
end

function TestRectangle.test_translate()
  local rectangle = Rectangle:new(Vector2D:new(10, 20), Vector2D:new(40, 60))
  local result = rectangle:translate(Vector2D:new(5, -10))

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(15, 10),
    Vector2D:new(45, 50)
  ))
end

function TestRectangle.test_add()
  local rectangle = Rectangle:new(Vector2D:new(10, 20), Vector2D:new(40, 60))
  local result = rectangle + Vector2D:new(5, -10)

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(15, 10),
    Vector2D:new(45, 50)
  ))
end

function TestRectangle.test_sub()
  local rectangle = Rectangle:new(Vector2D:new(10, 20), Vector2D:new(40, 60))
  local result = rectangle - Vector2D:new(5, -10)

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(5, 30),
    Vector2D:new(35, 70)
  ))
end

function TestRectangle.test_expand()
  local rectangle = Rectangle:new(Vector2D:new(10, 20), Vector2D:new(40, 60))
  local result = rectangle:expand(5)

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(5, 15),
    Vector2D:new(45, 65)
  ))
end

function TestRectangle.test_scale()
  local rectangle = Rectangle:new(Vector2D:new(10, 20), Vector2D:new(40, 60))
  local result = rectangle:scale(2)

  luaunit.assert_is_true(checks.is_instance(result, Rectangle))
  luaunit.assert_equals(result, Rectangle:new(
    Vector2D:new(-5, 0),
    Vector2D:new(55, 80)
  ))
end
