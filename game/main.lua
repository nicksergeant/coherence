local text, pos

function love.load(args)
    local msg = args[1] or nil
    text = love.graphics.newText(love.graphics.getFont(), msg)
    pos = {
        x = 50,
        y = 50,
    }

    print("Game started!")
end

function love.draw()
    love.graphics.draw(text, pos.x, pos.y)
end

function love.update(dt)
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
