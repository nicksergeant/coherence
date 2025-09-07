local portal = {}

portal.x = 1500
portal.y = 800
portal.width = 192
portal.height = 192
portal.sprite = nil
portal.spriteScale = 2

portal.collisionBox = {
    width = 285,
    height = 219,
    offsetX = 49,
    offsetY = 120,
}

portal.canInteract = false
portal.interactionZone = {
    x = 192 - 40,
    y = 300 - 20,
    width = 80,
    height = 80,
}

function portal.init()
    portal.sprite = love.graphics.newImage("assets/sprites/portal.png")
    portal.sprite:setFilter("nearest", "nearest")
end

function portal.onInteract()
    print("Entering portal... (TODO: load interior map)")
    -- TODO: Load interior tilemap and move player inside
end

function portal.addToWorld(world)
    world:add(
        portal,
        portal.x + portal.collisionBox.offsetX,
        portal.y + portal.collisionBox.offsetY,
        portal.collisionBox.width,
        portal.collisionBox.height
    )
end

function portal.update(_, player)
    local zoneX = portal.x + portal.interactionZone.x
    local zoneY = portal.y + portal.interactionZone.y

    local playerX = player.x + player.collisionBox.offsetX
    local playerY = player.y + player.collisionBox.offsetY
    local playerRight = playerX + player.collisionBox.width
    local playerBottom = playerY + player.collisionBox.height

    local zoneRight = zoneX + portal.interactionZone.width
    local zoneBottom = zoneY + portal.interactionZone.height

    portal.canInteract = playerX < zoneRight and playerRight > zoneX and playerY < zoneBottom and playerBottom > zoneY
end

function portal.draw()
    love.graphics.draw(portal.sprite, portal.x, portal.y, 0, portal.spriteScale, portal.spriteScale)

    if portal.canInteract then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", portal.x + 170, portal.y + 250, 44, 20)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Press X", portal.x + 172, portal.y + 252)
    end
end

return portal
