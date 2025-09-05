local lurker = require("lib.lurker")

lurker.postswap = function(f)
    print("Reloaded: " .. f)
    love.load()
end

local pos

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
    love.graphics.rectangle("fill", pos.x, pos.y, 36, 48, 50, 50, 1000)
    love.graphics.setColor(0, 0, 0, 1)
end

function love.update(dt)
    lurker.update()

    local speed = 200
    local move = speed * dt

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        pos.x = pos.x - move
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        pos.x = pos.x + move
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        pos.y = pos.y - move
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        pos.y = pos.y + move
    end
end
