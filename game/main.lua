local lurker = require("lib.lurker")
local bump = require("lib.bump")

local BUMP_CELL_SIZE = 64
local DEBUG_COLOR = { 1, 0, 0, 0.5 }
local PORTAL_DOOR_COLOR = { 0, 1, 0, 0.5 }

local game = {}
game.world = nil
game.debug = false
game.entities = {} -- All drawable entities

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

    game.entities = { game.player, game.portal }

    game.worldWidth = game.tilemap.mapWidth * game.tilemap.tileSize
    game.worldHeight = game.tilemap.mapHeight * game.tilemap.tileSize
    game.camera.init(game.player, game.worldWidth, game.worldHeight)
end

loadModules()

local function getSortY(entity)
    if entity.collisionBox then
        return entity.y + entity.collisionBox.offsetY + entity.collisionBox.height
    end
    return entity.y
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

    initializeGame(true)
end

function love.load()
    initializeGame(false)
    print("Game started!")
end

function love.draw()
    game.camera.apply()
    game.tilemap.draw(game.camera.x, game.camera.y)

    -- Y-sort and draw entities
    table.sort(game.entities, function(a, b)
        return getSortY(a) < getSortY(b)
    end)

    for _, entity in ipairs(game.entities) do
        entity.draw()
    end

    -- Debug visualization
    if game.debug then
        -- Draw collision boxes
        if game.world then
            love.graphics.setColor(DEBUG_COLOR)
            local items, len = game.world:getItems()

            for i = 1, len do
                local item = items[i]
                local x, y, w, h = game.world:getRect(item)
                love.graphics.rectangle("line", x, y, w, h)
            end
        end

        -- Draw interaction zones
        love.graphics.setColor(0, 1, 1, 0.3)
        for _, entity in ipairs(game.entities) do
            if entity.interactionZone then
                local x = entity.x + entity.interactionZone.x
                local y = entity.y + entity.interactionZone.y
                local w = entity.interactionZone.width
                local h = entity.interactionZone.height
                love.graphics.rectangle("fill", x, y, w, h)
                love.graphics.setColor(0, 1, 1, 1)
                love.graphics.rectangle("line", x, y, w, h)
                love.graphics.setColor(0, 1, 1, 0.3)
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
    elseif key == "x" then
        for _, entity in ipairs(game.entities) do
            if entity.canInteract and entity.onInteract then
                entity.onInteract()
                break
            end
        end
    end
end
