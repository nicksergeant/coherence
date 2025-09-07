local portal = {}

portal.x = 1500
portal.y = 800
portal.width = 64
portal.height = 64
portal.sprite = nil
portal.spriteScale = 2
portal.pulseTime = 0
portal.glowRadius = 0

function portal.init()
    portal.sprite = love.graphics.newImage("assets/sprites/portal.png")
    portal.sprite:setFilter("nearest", "nearest")
    portal.width = portal.sprite:getWidth() * portal.spriteScale
    portal.height = portal.sprite:getHeight() * portal.spriteScale
end

function portal.update(dt)
    portal.pulseTime = portal.pulseTime + dt * 2
    portal.glowRadius = 25 + math.sin(portal.pulseTime) * 5
end

function portal.draw()
    love.graphics.push()

    love.graphics.setColor(0.5, 0, 1, 0.2)
    love.graphics.circle("fill", portal.x + portal.width / 2, portal.y + portal.height / 2, portal.glowRadius)

    love.graphics.setColor(1, 1, 1, 1)
    if portal.sprite then
        love.graphics.draw(portal.sprite, portal.x, portal.y, 0, portal.spriteScale, portal.spriteScale)
    end

    love.graphics.pop()
end

function portal.checkCollision(player)
    local px = player.x
    local py = player.y
    local pw = player.width
    local ph = player.height

    if px < portal.x + portal.width and px + pw > portal.x and py < portal.y + portal.height and py + ph > portal.y then
        local doorLeft = portal.x + portal.width * 0.4
        local doorRight = portal.x + portal.width * 0.6
        local doorTop = portal.y + portal.height * 0.8

        if px + pw / 2 >= doorLeft and px + pw / 2 <= doorRight and py + ph >= doorTop then
            return "enter"
        else
            return "blocked"
        end
    end

    return false
end

return portal
