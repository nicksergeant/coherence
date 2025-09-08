local bump = require("lib.bump")

local overworld = {}

overworld.world = nil
overworld.entities = {}
overworld.worldWidth = 0
overworld.worldHeight = 0

-- Tilemap data
overworld.tileSize = 128
overworld.mapWidth = 96
overworld.mapHeight = 40
overworld.tiles = {}
overworld.grassImage = nil
overworld.scaleX = 1
overworld.scaleY = 1

local camera = require("camera")
local portal = require("entities.portal")

local BUMP_CELL_SIZE = 64

function overworld:initTilemap()
    self.grassImage = love.graphics.newImage("assets/tiles/grass.png")
    self.grassImage:setFilter("nearest", "nearest")
    self.scaleX = self.tileSize / self.grassImage:getWidth()
    self.scaleY = self.tileSize / self.grassImage:getHeight()

    for y = 1, self.mapHeight do
        self.tiles[y] = {}
        for x = 1, self.mapWidth do
            self.tiles[y][x] = 1
        end
    end
end

function overworld:drawTilemap(cameraX, cameraY)
    love.graphics.setColor(1, 1, 1, 1)

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Only render visible tiles
    local startX = math.max(1, math.floor(cameraX / self.tileSize) + 1)
    local startY = math.max(1, math.floor(cameraY / self.tileSize) + 1)
    local endX = math.min(self.mapWidth, math.ceil((cameraX + windowWidth) / self.tileSize))
    local endY = math.min(self.mapHeight, math.ceil((cameraY + windowHeight) / self.tileSize))

    for y = startY, endY do
        for x = startX, endX do
            if self.tiles[y][x] == 1 then
                love.graphics.draw(
                    self.grassImage,
                    (x - 1) * self.tileSize,
                    (y - 1) * self.tileSize,
                    0,
                    self.scaleX,
                    self.scaleY
                )
            end
        end
    end
end

function overworld:enter(player, transitionData)
    self:initTilemap()
    portal.init()

    self.world = bump.newWorld(BUMP_CELL_SIZE)

    if transitionData.fromRoom == "portal_interior" then
        player.x = portal.x + portal.interactionZone.x + portal.interactionZone.width / 2 - player.width / 2
        player.y = portal.y + portal.interactionZone.y + portal.interactionZone.height + 10
    end

    player.addToWorld(self.world)
    portal.addToWorld(self.world)

    self.entities = { player, portal }
    self.worldWidth = self.mapWidth * self.tileSize
    self.worldHeight = self.mapHeight * self.tileSize

    camera.init(player, self.worldWidth, self.worldHeight)
end

function overworld:exit()
    if self.world then
        self.world = nil
    end
end

function overworld:update(dt, player)
    player.update(dt, self.worldWidth, self.worldHeight)
    portal.update(dt, player)
    camera.update(player, self.worldWidth, self.worldHeight)
end

local function getSortY(entity)
    if entity.collisionBox then
        return entity.y + entity.collisionBox.offsetY + entity.collisionBox.height
    end
    return entity.y
end

function overworld:draw()
    camera.apply()
    self:drawTilemap(camera.x, camera.y)

    table.sort(self.entities, function(a, b)
        return getSortY(a) < getSortY(b)
    end)

    for _, entity in ipairs(self.entities) do
        entity.draw()
    end
end

function overworld:keypressed(key)
    if key == "x" then
        for _, entity in ipairs(self.entities) do
            if entity.canInteract and entity.onInteract then
                entity.onInteract()
                break
            end
        end
    end
end

function overworld:drawDebug()
    if self.world then
        love.graphics.setColor(1, 0, 0, 0.5)
        local items, len = self.world:getItems()

        for i = 1, len do
            local item = items[i]
            local x, y, w, h = self.world:getRect(item)
            love.graphics.rectangle("line", x, y, w, h)
        end
    end

    love.graphics.setColor(0, 1, 1, 0.3)
    for _, entity in ipairs(self.entities) do
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

return overworld
