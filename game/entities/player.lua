local player = {}

local WALK_SPEED = 250
local RUN_SPEED = 500

local BOB_SPEED = 17.5
local BOB_HEIGHT = 2.5

local DIAGONAL_FACTOR = 0.707

local SHADOW_WIDTH = 26
local SHADOW_HEIGHT = 8
local SHADOW_OFFSET_Y = 1

player.x = 750
player.y = 400
player.width = 48
player.height = 48
player.collisionBox = {
    width = 67,
    height = 48,
    offsetX = 13,
    offsetY = 56,
}
player.speed = WALK_SPEED
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
    world:add(
        player,
        player.x + player.collisionBox.offsetX,
        player.y + player.collisionBox.offsetY,
        player.collisionBox.width,
        player.collisionBox.height
    )
    player.world = world
end

function player.update(dt, worldWidth, worldHeight)
    -- Movement input and speed
    local speed = WALK_SPEED
    ---@diagnostic disable-next-line: param-type-mismatch
    if love.keyboard.isDown("rshift") or love.keyboard.isDown("lshift") then
        speed = RUN_SPEED
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
        dx = dx * DIAGONAL_FACTOR
        dy = dy * DIAGONAL_FACTOR
    end

    -- Movement and collision
    local goalX = player.x + dx * speed * dt
    local goalY = player.y + dy * speed * dt

    -- Calculate collision box goal position
    local collisionGoalX = goalX + player.collisionBox.offsetX
    local collisionGoalY = goalY + player.collisionBox.offsetY

    -- Clamp to world bounds
    collisionGoalX = math.max(0, math.min(collisionGoalX, worldWidth - player.collisionBox.width))
    collisionGoalY = math.max(0, math.min(collisionGoalY, worldHeight - player.collisionBox.height))

    local actualX, actualY, cols, len = player.world:move(player, collisionGoalX, collisionGoalY)

    -- Update sprite position from collision box position
    player.x = actualX - player.collisionBox.offsetX
    player.y = actualY - player.collisionBox.offsetY
    player.collisions = cols
    player.collisionCount = len

    -- Bobbing animation
    player.isMoving = (dx ~= 0 or dy ~= 0)
    if player.isMoving then
        player.bobTime = player.bobTime + dt * BOB_SPEED

        local bobCycle = player.bobTime % (math.pi * 2)
        local quarterCycle = math.pi / 2

        if bobCycle < quarterCycle * 0.3 or bobCycle > math.pi * 2 - quarterCycle * 0.3 then
            player.bobOffset = 0
        elseif bobCycle < math.pi - quarterCycle * 0.3 then
            player.bobOffset = BOB_HEIGHT
        elseif bobCycle < math.pi + quarterCycle * 0.3 then
            player.bobOffset = 0
        else
            player.bobOffset = -BOB_HEIGHT
        end
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
        local spriteWidth = currentSprite:getWidth() * player.spriteScale

        -- Shadow
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.ellipse(
            "fill",
            player.x + spriteWidth / 2,
            player.y + spriteHeight + SHADOW_OFFSET_Y,
            SHADOW_WIDTH,
            SHADOW_HEIGHT
        )
        love.graphics.setColor(1, 1, 1, 1)

        love.graphics.draw(currentSprite, player.x, drawY, 0, player.spriteScale, player.spriteScale)
    end
end

return player
