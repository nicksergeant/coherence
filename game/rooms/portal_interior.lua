local bump = require("lib.bump")

local portal_interior = {}

portal_interior.world = nil
portal_interior.entities = {}
portal_interior.worldWidth = 0
portal_interior.worldHeight = 0

local camera = require("camera")

local BUMP_CELL_SIZE = 64
local TILE_SIZE = 32
local MAP_WIDTH = 32
local MAP_HEIGHT = 24

local WALL = 1
local FLOOR = 2

local map = {}
for y = 1, MAP_HEIGHT do
    map[y] = {}
    for x = 1, MAP_WIDTH do
        if y == 1 or y == MAP_HEIGHT or x == 1 or x == MAP_WIDTH then
            map[y][x] = WALL
        else
            map[y][x] = FLOOR
        end
    end
end

function portal_interior:enter(player)
    self.world = bump.newWorld(BUMP_CELL_SIZE)

    player.x = love.graphics.getWidth() / 2 - player.width / 2
    player.y = love.graphics.getHeight() - 150
    player.addToWorld(self.world)

    self.entities = { player }
    self.worldWidth = MAP_WIDTH * TILE_SIZE
    self.worldHeight = MAP_HEIGHT * TILE_SIZE

    camera.init(player, self.worldWidth, self.worldHeight)
end

function portal_interior:exit()
    if self.world then
        self.world = nil
    end
end

function portal_interior:update(dt, player)
    player.update(dt, self.worldWidth, self.worldHeight)
    camera.update(player, self.worldWidth, self.worldHeight)
end

function portal_interior:draw()
    camera.apply()
    self:drawTilemap(camera.x, camera.y)

    for _, entity in ipairs(self.entities) do
        entity.draw()
    end

    self:drawExitPrompt()
end

function portal_interior.drawTilemap(_, cameraX, cameraY)
    local startX = math.max(1, math.floor(cameraX / TILE_SIZE))
    local endX = math.min(MAP_WIDTH, math.ceil((cameraX + love.graphics.getWidth()) / TILE_SIZE))
    local startY = math.max(1, math.floor(cameraY / TILE_SIZE))
    local endY = math.min(MAP_HEIGHT, math.ceil((cameraY + love.graphics.getHeight()) / TILE_SIZE))

    for y = startY, endY do
        for x = startX, endX do
            local tile = map[y][x]
            if tile == WALL then
                love.graphics.setColor(0.3, 0.3, 0.3, 1)
            elseif tile == FLOOR then
                love.graphics.setColor(0.15, 0.15, 0.15, 1)
            end
            love.graphics.rectangle("fill", (x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE, TILE_SIZE, TILE_SIZE)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function portal_interior:drawExitPrompt()
    local player = self.entities[1]
    if player and player.y > love.graphics.getHeight() - 200 then
        local screenWidth = love.graphics.getWidth()
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", screenWidth / 2 - 50, love.graphics.getHeight() - 80, 100, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Press X to Exit", screenWidth / 2 - 48, love.graphics.getHeight() - 78)
    end
end

function portal_interior.keypressed(_, key)
    if key == "x" then
        local room_manager = require("room_manager")
        room_manager.switch("overworld", { fromRoom = "portal_interior" })
    end
end

function portal_interior:drawDebug()
    if self.world then
        love.graphics.setColor(1, 0, 0, 0.5)
        local items, len = self.world:getItems()

        for i = 1, len do
            local item = items[i]
            local x, y, w, h = self.world:getRect(item)
            love.graphics.rectangle("line", x, y, w, h)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return portal_interior
