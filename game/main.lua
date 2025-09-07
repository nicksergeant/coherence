local lurker = require("lib.lurker")
local bump = require("lib.bump")

local BUMP_CELL_SIZE = 64
local DEBUG_COLOR = { 1, 0, 0, 0.5 }
local PORTAL_DOOR_COLOR = { 0, 1, 0, 0.5 }

local game = {}
game.world = nil
game.debug = false

local function loadModules()
    package.loaded.player = nil
    package.loaded.tilemap = nil
    package.loaded.camera = nil
    package.loaded.portal = nil

    game.player = require("player")
    game.tilemap = require("tilemap")
    game.camera = require("camera")
    game.portal = require("portal")
end

local function initializeGame(keepPlayerPosition)
    game.tilemap.init()
    game.player.init()
    game.portal.init()

    game.world = bump.newWorld(BUMP_CELL_SIZE)

    if not keepPlayerPosition then
        game.player.x = love.graphics.getWidth() / 2
        game.player.y = love.graphics.getHeight() / 2
    end

    game.player.addToWorld(game.world)
    game.portal.addToWorld(game.world)

    game.worldWidth = game.tilemap.mapWidth * game.tilemap.tileSize
    game.worldHeight = game.tilemap.mapHeight * game.tilemap.tileSize
    game.camera.init(game.player, game.worldWidth, game.worldHeight)
end

loadModules()

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

    initializeGame(true)
end

function love.load()
    initializeGame(false)
    print("Game started!")
end

function love.draw()
    game.camera.apply()
    game.tilemap.draw(game.camera.x, game.camera.y)
    game.portal.draw()
    game.player.draw()

    -- Debug visualization
    if game.debug and game.world then
        love.graphics.setColor(DEBUG_COLOR)
        local items, len = game.world:getItems()

        for i = 1, len do
            local item = items[i]
            local x, y, w, h = game.world:getRect(item)
            love.graphics.rectangle("line", x, y, w, h)

            if item.type == "portalDoor" then
                love.graphics.setColor(PORTAL_DOOR_COLOR)
                love.graphics.rectangle("fill", x, y, w, h)
                love.graphics.setColor(DEBUG_COLOR)
            end
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
end

function love.update(dt)
    lurker.update()
    game.player.update(dt, game.worldWidth, game.worldHeight)
    game.portal.update(dt, game.player)
    game.camera.update(game.player, game.worldWidth, game.worldHeight)
end

function love.keypressed(key)
    if key == "f1" then
        game.debug = not game.debug
    elseif key == "f2" then
        game.player.useGirlSprites = not game.player.useGirlSprites
    end
end
