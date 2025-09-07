local portal = {}

portal.x = 1500
portal.y = 800
portal.width = 192
portal.height = 192
portal.sprite = nil
portal.spriteScale = 2

portal.collisionBox = {
    width = 285,
    height = 336,
    offsetX = 49,
    offsetY = 3,
}

portal.doorTrigger = {
    type = "portalDoor",
    parent = portal,
    width = 101,
    height = 77,
    offsetX = 141,
    offsetY = 305,
}

function portal.init()
    portal.sprite = love.graphics.newImage("assets/sprites/portal.png")
    portal.sprite:setFilter("nearest", "nearest")
end

function portal.addToWorld(world)
    -- Main collision box
    world:add(
        portal,
        portal.x + portal.collisionBox.offsetX,
        portal.y + portal.collisionBox.offsetY,
        portal.collisionBox.width,
        portal.collisionBox.height
    )

    -- Door trigger zone
    world:add(
        portal.doorTrigger,
        portal.x + portal.doorTrigger.offsetX,
        portal.y + portal.doorTrigger.offsetY,
        portal.doorTrigger.width,
        portal.doorTrigger.height
    )
end

function portal.update(_, player)
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
    love.graphics.draw(portal.sprite, portal.x, portal.y, 0, portal.spriteScale, portal.spriteScale)
end

return portal
