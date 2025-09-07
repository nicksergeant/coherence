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
player.insideObject = nil
player.world = nil
player.useGirlSprites = false

function player.init()
    player.sprites.down = love.graphics.newImage("assets/sprites/player_down.png")
    player.sprites.up = love.graphics.newImage("assets/sprites/player_up.png")
    player.sprites.left = love.graphics.newImage("assets/sprites/player_left.png")
    player.sprites.right = love.graphics.newImage("assets/sprites/player_right.png")

    player.sprites.down_girl = love.graphics.newImage("assets/sprites/player_down_girl.png")
    player.sprites.up_girl = love.graphics.newImage("assets/sprites/player_up_girl.png")
    player.sprites.left_girl = love.graphics.newImage("assets/sprites/player_left_girl.png")
    player.sprites.right_girl = love.graphics.newImage("assets/sprites/player_right_girl.png")

    for _, sprite in pairs(player.sprites) do
        sprite:setFilter("nearest", "nearest")
    end
end

function player.addToWorld(world)
    world:add(player, player.x, player.y, player.width, player.height)
    player.world = world
end

function player.update(dt, worldWidth, worldHeight)
    local speed = player.speed

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

    local goalX = player.x + dx * speed * dt
    local goalY = player.y + dy * speed * dt

    goalX = math.max(0, math.min(goalX, worldWidth - player.width))
    goalY = math.max(0, math.min(goalY, worldHeight - player.height))

    local actualX, actualY, cols, len = player.world:move(player, goalX, goalY)

    player.x = actualX
    player.y = actualY

    player.collisions = cols
    player.collisionCount = len

    player.isMoving = (dx ~= 0 or dy ~= 0)
    if player.isMoving then
        player.bobTime = player.bobTime + dt * 12
        player.bobOffset = math.sin(player.bobTime) * 2
    else
        player.bobTime = 0
        player.bobOffset = 0
    end
end

function player.draw()
    if player.insideObject then
        return
    end

    local spriteKey = player.direction
    if player.useGirlSprites then
        spriteKey = player.direction .. "_girl"
    end

    local currentSprite = player.sprites[spriteKey]
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
