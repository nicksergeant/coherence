local lurker = require("lib.lurker")

local game = {}

local function loadModules()
    package.loaded.player = nil
    package.loaded.tilemap = nil
    package.loaded.camera = nil

    game.player = require("player")
    game.tilemap = require("tilemap")
    game.camera = require("camera")
end

local function initializeGame(keepPlayerPosition)
    game.tilemap.init()

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
    game.player.draw()
end

function love.update(dt)
    lurker.update()
    game.player.update(dt, game.worldWidth, game.worldHeight)
    game.camera.update(game.player, game.worldWidth, game.worldHeight)
end
