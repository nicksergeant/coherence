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

function portal.addToWorld(world)
    local portalSolidX = portal.x + portal.width * 0.15
    local portalSolidY = portal.y + portal.height * 0.15
    local portalSolidWidth = portal.width * 0.7
    local portalSolidHeight = portal.height * 0.6

    world:add(portal, portalSolidX, portalSolidY, portalSolidWidth, portalSolidHeight)

    portal.doorTrigger = { type = "portalDoor", parent = portal }

    local doorWidth = portal.width * 0.25
    local doorHeight = portal.height * 0.2
    local doorX = portal.x + portal.width * 0.375
    local doorY = portal.y + portal.height * 0.75

    world:add(portal.doorTrigger, doorX, doorY, doorWidth, doorHeight)
end

function portal.update(dt, player)
    portal.pulseTime = portal.pulseTime + dt * 2
    portal.glowRadius = 25 + math.sin(portal.pulseTime) * 5

    if player.collisions then
        for i = 1, player.collisionCount do
            local col = player.collisions[i]
            if col.other == portal.doorTrigger then
                player.insideObject = portal
                return
            end
        end
    end

    if player.insideObject == portal then
        player.insideObject = nil
    end
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

return portal
