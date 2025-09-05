local lurker = require("lib.lurker")

lurker.postswap = function(f)
    print("Reloaded: " .. f)
    love.load()
end

local pos
local playerWidth = 36
local playerHeight = 48

function love.load()
    love.graphics.setBackgroundColor(0.9, 0.9, 0.9, 1)
    pos = {
        x = 750,
        y = 400,
    }
    print("Game started!")
end

function love.draw()
    love.graphics.setColor(0.093, 0.673, 0.999, 1.0)
    love.graphics.rectangle("fill", pos.x, pos.y, playerWidth, playerHeight, 50, 50, 1000)
    love.graphics.setColor(0, 0, 0, 1)
end

function love.update(dt)
    lurker.update()

    local speed = 200

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

    pos.x = pos.x + dx * speed * dt
    pos.y = pos.y + dy * speed * dt

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    pos.x = math.max(0, math.min(pos.x, windowWidth - playerWidth))
    pos.y = math.max(0, math.min(pos.y, windowHeight - playerHeight))
end
