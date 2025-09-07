local lurker = require("lib.lurker")

local game = {}

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

    if not keepPlayerPosition then
        game.player.x = love.graphics.getWidth() / 2
        game.player.y = love.graphics.getHeight() / 2
    end

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
end

function love.update(dt)
    lurker.update()
    game.player.update(dt, game.worldWidth, game.worldHeight)
    
    local portalCollision = game.portal.checkCollision(game.player)
    if portalCollision == "blocked" then
        game.player.x = game.player.prevX
        game.player.y = game.player.prevY
        game.player.isInPortal = false
    elseif portalCollision == "enter" then
        game.player.isInPortal = true
    else
        game.player.isInPortal = false
    end
    
    game.camera.update(game.player, game.worldWidth, game.worldHeight)
    game.portal.update(dt)
end
