local tilemap = {}

tilemap.tileSize = 128
tilemap.mapWidth = 96
tilemap.mapHeight = 40
tilemap.tiles = {}
tilemap.grassImage = nil
tilemap.scaleX = 1
tilemap.scaleY = 1

function tilemap.init()
    tilemap.grassImage = love.graphics.newImage("assets/tiles/grass.png")
    tilemap.grassImage:setFilter("nearest", "nearest")
    tilemap.scaleX = tilemap.tileSize / tilemap.grassImage:getWidth()
    tilemap.scaleY = tilemap.tileSize / tilemap.grassImage:getHeight()

    for y = 1, tilemap.mapHeight do
        tilemap.tiles[y] = {}
        for x = 1, tilemap.mapWidth do
            tilemap.tiles[y][x] = 1
        end
    end
end

function tilemap.draw(cameraX, cameraY)
    love.graphics.setColor(1, 1, 1, 1)

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    local startX = math.max(1, math.floor(cameraX / tilemap.tileSize) + 1)
    local startY = math.max(1, math.floor(cameraY / tilemap.tileSize) + 1)
    local endX = math.min(tilemap.mapWidth, math.ceil((cameraX + windowWidth) / tilemap.tileSize))
    local endY = math.min(tilemap.mapHeight, math.ceil((cameraY + windowHeight) / tilemap.tileSize))

    for y = startY, endY do
        for x = startX, endX do
            if tilemap.tiles[y][x] == 1 then
                love.graphics.draw(
                    tilemap.grassImage,
                    (x - 1) * tilemap.tileSize,
                    (y - 1) * tilemap.tileSize,
                    0,
                    tilemap.scaleX,
                    tilemap.scaleY
                )
            end
        end
    end
end


return tilemap
