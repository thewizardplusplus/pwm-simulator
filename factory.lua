---
-- @module factory

local assertions = require("luatypechecks.assertions")
local json = require("luaserialization.json")
local GameSettings = require("models.gamesettings")

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

return factory
