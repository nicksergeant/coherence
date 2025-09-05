local lurker = require("lib.lurker")

lurker.postswap = function(f)
    print("Reloaded: " .. f)
    love.load()
end

local text, pos

function love.load()
    pos = {
        x = 50,
        y = 50,
    }
    text = love.graphics.newText(love.graphics.getFont(), "Hello World")
    print("Game started!")
end

function love.draw()
    love.graphics.draw(text, pos.x, pos.y)
end

function love.update(dt)
    lurker.update()

    local speed = 100
    local move = speed * dt

    if love.keyboard.isDown("left") then
        pos.x = pos.x - move
    end
    if love.keyboard.isDown("right") then
        pos.x = pos.x + move
    end
    if love.keyboard.isDown("up") then
        pos.y = pos.y - move
    end
    if love.keyboard.isDown("down") then
        pos.y = pos.y + move
    end
end
