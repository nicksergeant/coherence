local portal = {}

local SPRITE_SCALE = 2

local SOLID_OFFSET_X = 0.15
local SOLID_OFFSET_Y = 0.15
local SOLID_WIDTH_FACTOR = 0.7
local SOLID_HEIGHT_FACTOR = 0.6

local DOOR_WIDTH_FACTOR = 0.25
local DOOR_HEIGHT_FACTOR = 0.2
local DOOR_OFFSET_X = 0.375
local DOOR_OFFSET_Y = 0.75

portal.x = 1500
portal.y = 800
portal.width = 64
portal.height = 64
portal.sprite = nil
portal.spriteScale = SPRITE_SCALE

function portal.init()
    portal.sprite = love.graphics.newImage("assets/sprites/portal.png")
    portal.sprite:setFilter("nearest", "nearest")
    portal.width = portal.sprite:getWidth() * portal.spriteScale
    portal.height = portal.sprite:getHeight() * portal.spriteScale
end

function portal.addToWorld(world)
    local portalSolidX = portal.x + portal.width * SOLID_OFFSET_X
    local portalSolidY = portal.y + portal.height * SOLID_OFFSET_Y
    local portalSolidWidth = portal.width * SOLID_WIDTH_FACTOR
    local portalSolidHeight = portal.height * SOLID_HEIGHT_FACTOR

    world:add(portal, portalSolidX, portalSolidY, portalSolidWidth, portalSolidHeight)

    portal.doorTrigger = { type = "portalDoor", parent = portal }

    local doorWidth = portal.width * DOOR_WIDTH_FACTOR
    local doorHeight = portal.height * DOOR_HEIGHT_FACTOR
    local doorX = portal.x + portal.width * DOOR_OFFSET_X
    local doorY = portal.y + portal.height * DOOR_OFFSET_Y

    world:add(portal.doorTrigger, doorX, doorY, doorWidth, doorHeight)
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
