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

    -- Adjust collision box to account for transparent areas
    local portalLeft = portal.x + portal.width * 0
    local portalRight = portal.x + portal.width * 0.83
    local portalTop = portal.y - portal.height * 0.155
    local portalBottom = portal.y + portal.height - 100

    if px < portalRight and px + pw > portalLeft and py < portalBottom and py + ph > portalTop then
        local doorLeft = portal.x + portal.width * 0.35
        local doorRight = portal.x + portal.width * 0.65
        local doorTop = portal.y + portal.height * 0.7

        -- Check if player center is in the door area
        local playerCenterX = px + pw / 2
        local playerCenterY = py + ph / 2

        if playerCenterX >= doorLeft and playerCenterX <= doorRight and py + ph >= doorTop then
            -- Player is at the door entrance or already inside
            return "enter"
        elseif
            playerCenterY >= portalTop
            and playerCenterY <= portalBottom
            and playerCenterX >= portalLeft
            and playerCenterX <= portalRight
        then
            -- Player is already inside the portal area, keep them hidden
            return "inside"
        else
            return "blocked"
        end
    end

    return false
end

return portal
