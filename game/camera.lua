local camera = {}

camera.x = 0
camera.y = 0

function camera.init(player, worldWidth, worldHeight)
    camera.update(player, worldWidth, worldHeight)
end

function camera.update(player, worldWidth, worldHeight)
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    camera.x = player.x + player.width / 2 - windowWidth / 2
    camera.y = player.y + player.height / 2 - windowHeight / 2

    camera.x = math.max(0, math.min(camera.x, worldWidth - windowWidth))
    camera.y = math.max(0, math.min(camera.y, worldHeight - windowHeight))
end

function camera.apply()
    love.graphics.translate(-camera.x, -camera.y)
end

return camera
