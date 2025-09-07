local player = {}

player.x = 750
player.y = 400
player.width = 32
player.height = 40
player.speed = 200
player.direction = "down"
player.sprites = {}
player.spriteScale = 2
player.isMoving = false
player.bobOffset = 0
player.bobTime = 0
player.isInPortal = false
player.prevX = 0
player.prevY = 0

function player.update(dt, worldWidth, worldHeight)
    local speed = player.speed
    
    player.prevX = player.x
    player.prevY = player.y

    ---@diagnostic disable-next-line: param-type-mismatch
    if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
        speed = 100
    end

    local dx, dy = 0, 0

    if love.keyboard.isDown("a") then
        dx = -1
    end
    if love.keyboard.isDown("d") then
        dx = 1
    end
    if love.keyboard.isDown("w") then
        dy = -1
    end
    if love.keyboard.isDown("s") then
        dy = 1
    end

    if dx < 0 then
        player.direction = "left"
    elseif dx > 0 then
        player.direction = "right"
    elseif dy < 0 then
        player.direction = "up"
    elseif dy > 0 then
        player.direction = "down"
    end

    if dx ~= 0 and dy ~= 0 then
        dx = dx * 0.707
        dy = dy * 0.707
    end

    player.x = player.x + dx * speed * dt
    player.y = player.y + dy * speed * dt

    player.x = math.max(0, math.min(player.x, worldWidth - player.width))
    player.y = math.max(0, math.min(player.y, worldHeight - player.height))

    player.isMoving = (dx ~= 0 or dy ~= 0)
    if player.isMoving then
        player.bobTime = player.bobTime + dt * 12
        player.bobOffset = math.sin(player.bobTime) * 2
    else
        player.bobTime = 0
        player.bobOffset = 0
    end
end

function player.init()
    player.sprites.down = love.graphics.newImage("assets/sprites/player_down.png")
    player.sprites.up = love.graphics.newImage("assets/sprites/player_up.png")
    player.sprites.left = love.graphics.newImage("assets/sprites/player_left.png")
    player.sprites.right = love.graphics.newImage("assets/sprites/player_right.png")

    for _, sprite in pairs(player.sprites) do
        sprite:setFilter("nearest", "nearest")
    end
end

function player.draw()
    if player.isInPortal then
        return
    end
    
    local currentSprite = player.sprites[player.direction]
    if currentSprite then
        local drawY = player.y + player.bobOffset
        local spriteHeight = currentSprite:getHeight() * player.spriteScale

        love.graphics.setColor(0, 0, 0, 0.5)
        local spriteWidth = currentSprite:getWidth() * player.spriteScale
        love.graphics.ellipse("fill", player.x + spriteWidth / 2, player.y + spriteHeight + 1, 26, 8)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(currentSprite, player.x, drawY, 0, player.spriteScale, player.spriteScale)
    end
end

return player
