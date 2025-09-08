local lurker = require("lib.lurker")
local room_manager = require("room_manager")

local game = {}
game.debug = false
game.player = nil

local function loadModules()
    package.loaded["entities.player"] = nil
    package.loaded["entities.portal"] = nil
    package.loaded["rooms.overworld"] = nil
    package.loaded["rooms.portal_interior"] = nil
    package.loaded.camera = nil
    package.loaded.room_manager = nil

    room_manager = require("room_manager")
    game.player = require("entities.player")

    local overworld = require("rooms.overworld")
    local portal_interior = require("rooms.portal_interior")

    room_manager.register("overworld", overworld)
    room_manager.register("portal_interior", portal_interior)
end

lurker.preswap = function()
    if game.player then
        game.savedPlayerX = game.player.x
        game.savedPlayerY = game.player.y
    end
end

lurker.postswap = function(f)
    print("Reloaded: " .. f)

    loadModules()

    if game.savedPlayerX then
        game.player.x = game.savedPlayerX
        game.player.y = game.savedPlayerY
    end

    game.player.init()
    room_manager.init(game.player)
    room_manager.switch("overworld", {})
end

function love.load()
    loadModules()
    game.player.init()
    room_manager.init(game.player)
    room_manager.switch("overworld", {})
    print("Game started!")
end

function love.draw()
    room_manager.draw()

    if game.debug and room_manager.current and room_manager.current.drawDebug then
        room_manager.current:drawDebug()
    end
end

function love.update(dt)
    lurker.update()
    room_manager.update(dt)
end

function love.keypressed(key)
    if key == "f1" then
        game.debug = not game.debug
    elseif key == "f2" then
        game.player.useGirlSprites = not game.player.useGirlSprites
    else
        room_manager.keypressed(key)
    end
end
