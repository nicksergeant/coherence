local player = {}

player.x = 750
player.y = 400
player.width = 36
player.height = 48
player.speed = 200

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

    if dx ~= 0 and dy ~= 0 then
        dx = dx * 0.707
        dy = dy * 0.707
    end

    player.x = player.x + dx * speed * dt
    player.y = player.y + dy * speed * dt

    player.x = math.max(0, math.min(player.x, worldWidth - player.width))
    player.y = math.max(0, math.min(player.y, worldHeight - player.height))
end

function player.draw()
    love.graphics.setColor(0, 0, 0, 1.0)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height, 50, 50, 1000)
    love.graphics.setColor(1, 1, 1, 1)
end

return player
