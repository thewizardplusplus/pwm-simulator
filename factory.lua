---
-- @module factory

local assertions = require("luatypechecks.assertions")
local json = require("luaserialization.json")
local GameSettings = require("models.gamesettings")
local StatsStorage = require("statsstorage")

local factory = {}

---
-- @tparam string path
-- @treturn GameSettings
-- @error error message
function factory.create_game_settings(path)
  assertions.is_string(path)

  local settings, err = json.load_from_json(
    path,
    GameSettings.schema(),
    { GameSettings = GameSettings.from_options },
    function(path) -- luacheck: no redefined
      assertions.is_string(path)

      local data, err = love.filesystem.read(path)
      return data, data == nil and err or nil
    end
  )
  if not settings then
    return nil, "unable to load the settings: " .. err
  end

  return settings
end

---
-- @tparam string path
-- @treturn StatsStorage
-- @error error message
function factory.create_stats_storage(path)
  assertions.is_string(path)

  local ok = love.filesystem.createDirectory(path)
  if not ok then
    return nil, "unable to create the stats DB"
  end

  local full_path = love.filesystem.getSaveDirectory() .. "/" .. path
  return StatsStorage:new(full_path)
end

return factory
