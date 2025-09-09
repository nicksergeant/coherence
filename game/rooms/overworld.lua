local bump = require("lib.bump")

local overworld = {}

overworld.world = nil
overworld.entities = {}
overworld.worldWidth = 0
overworld.worldHeight = 0

-- Tilemap data
overworld.tileSize = 128
overworld.mapWidth = 40
overworld.mapHeight = 30
overworld.tiles = {}
overworld.grassImage = nil
overworld.snowImage = nil
overworld.fireImage = nil
overworld.scaleX = 1
overworld.scaleY = 1

-- Universe system
overworld.currentUniverse = "utopian"
overworld.universes = {
    utopian = {
        tileColor = { 1, 1, 1, 1 },
        tileType = "grass",
        ambientShake = 0,
        name = "Utopian",
        timer = nil, -- No timer initially
        returnTimer = 60, -- 60 seconds when returning from other universes
        thought = "This feels safe... for now",
    },
    neutral = {
        tileColor = { 1, 1, 1, 1 }, -- Normal color, use snow tile
        tileType = "snow",
        ambientShake = 0,
        name = "Neutral",
        timer = 30, -- 30 seconds to get back
        thought = "Cold... must find the box",
    },
    dystopian = {
        tileColor = { 1, 1, 1, 1 }, -- Normal color for fire tile
        tileType = "fire",
        ambientShake = 0, -- Will be randomly varied
        name = "Dystopian",
        timer = 10, -- 10 seconds to get back
        thought = "Danger! Must find the box NOW",
    },
}
overworld.timer = 0
overworld.shakeAmount = 0
overworld.shakeDuration = 0
overworld.shakeOffsetX = 0
overworld.shakeOffsetY = 0
overworld.dystopianShakeTimer = 0
overworld.dystopianShakeMode = "calm"
overworld.gameOver = false

-- Thought bubble system
overworld.currentThought = ""
overworld.thoughtTimer = 0
overworld.THOUGHT_DURATION = 3

overworld.hasLeftUtopianBefore = false
overworld.isFirstSpawn = true

local camera = require("camera")
local portal = require("entities.portal")

local BUMP_CELL_SIZE = 64
local UNIVERSE_SHAKE_DURATION = 0.5
local UNIVERSE_SHAKE_AMOUNT = 30

function overworld:initTilemap()
    self.grassImage = love.graphics.newImage("assets/tiles/grass.png")
    self.grassImage:setFilter("nearest", "nearest")

    -- Create snow tile if it doesn't exist
    if not love.filesystem.getInfo("assets/tiles/snow.png") then
        self:generateSnowTile()
    end
    self.snowImage = love.graphics.newImage("assets/tiles/snow.png")
    self.snowImage:setFilter("nearest", "nearest")

    -- Load fire tile
    if love.filesystem.getInfo("assets/tiles/fire.png") then
        self.fireImage = love.graphics.newImage("assets/tiles/fire.png")
        self.fireImage:setFilter("nearest", "nearest")
    else
        -- Fallback to grass if fire doesn't exist
        self.fireImage = self.grassImage
    end

    self.scaleX = self.tileSize / self.grassImage:getWidth()
    self.scaleY = self.tileSize / self.grassImage:getHeight()

    for y = 1, self.mapHeight do
        self.tiles[y] = {}
        for x = 1, self.mapWidth do
            self.tiles[y][x] = 1
        end
    end
end

function overworld:generateSnowTile()
    -- Generate a simple snow tile
    local size = 128
    local imageData = love.image.newImageData(size, size)

    for x = 0, size - 1 do
        for y = 0, size - 1 do
            -- Base snow color with slight variation
            local noise = love.math.random() * 0.1
            local brightness = 0.85 + noise

            -- Add some texture
            if love.math.random() < 0.02 then
                brightness = brightness + 0.1
            end

            -- Clamp values
            brightness = math.min(1, brightness)

            imageData:setPixel(x, y, brightness, brightness * 0.98, brightness * 1.02, 1)
        end
    end

    -- Save the snow tile
    imageData:encode("png", "assets/tiles/snow.png")
end

function overworld:drawTilemap(cameraX, cameraY)
    local universe = self.universes[self.currentUniverse]
    love.graphics.setColor(universe.tileColor)

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Only render visible tiles
    local startX = math.max(1, math.floor(cameraX / self.tileSize) + 1)
    local startY = math.max(1, math.floor(cameraY / self.tileSize) + 1)
    local endX = math.min(self.mapWidth, math.ceil((cameraX + windowWidth) / self.tileSize))
    local endY = math.min(self.mapHeight, math.ceil((cameraY + windowHeight) / self.tileSize))

    -- Choose which tile to use based on universe
    local tileImage
    if universe.tileType == "snow" then
        tileImage = self.snowImage
    elseif universe.tileType == "fire" then
        tileImage = self.fireImage
    else
        tileImage = self.grassImage
    end

    for y = startY, endY do
        for x = startX, endX do
            if self.tiles[y][x] == 1 then
                love.graphics.draw(
                    tileImage,
                    (x - 1) * self.tileSize,
                    (y - 1) * self.tileSize,
                    0,
                    self.scaleX,
                    self.scaleY
                )
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function overworld:switchUniverse(newUniverse, player)
    if self.universes[newUniverse] then
        -- Track if we're leaving utopian for the first time
        if self.currentUniverse == "utopian" and newUniverse ~= "utopian" then
            self.hasLeftUtopianBefore = true
        end

        self.currentUniverse = newUniverse
        self.shakeAmount = UNIVERSE_SHAKE_AMOUNT
        self.shakeDuration = UNIVERSE_SHAKE_DURATION

        local universe = self.universes[newUniverse]

        -- Show thought bubble
        self.currentThought = universe.thought
        self.thoughtTimer = self.THOUGHT_DURATION

        -- Reset timer for timed universes
        if newUniverse == "utopian" and self.hasLeftUtopianBefore then
            -- Only set timer when returning to utopian after leaving
            self.timer = universe.returnTimer or 0
        elseif universe.timer then
            self.timer = universe.timer
        else
            self.timer = 0
        end

        -- Randomly position BOTH portal and player when universe jumping (but not first spawn)
        if not self.isFirstSpawn then
            local portal = self.entities[2] -- Get portal from entities

            if portal then
                -- First, remove portal from collision world to reposition it
                if self.world then
                    self.world:remove(portal)
                end

                -- Randomly position the portal
                portal.x = 200 + love.math.random() * (self.worldWidth - 600 - portal.width)
                portal.y = 200 + love.math.random() * (self.worldHeight - 600 - portal.height)

                -- Re-add portal to collision world at new position
                if self.world then
                    self.world:add(
                        portal,
                        portal.x + portal.collisionBox.offsetX,
                        portal.y + portal.collisionBox.offsetY,
                        portal.collisionBox.width,
                        portal.collisionBox.height
                    )
                end

                -- Now position player FAR from the new portal position
                local minDistance = 1500
                local maxAttempts = 50
                local attempts = 0

                repeat
                    player.x = 200 + love.math.random() * (self.worldWidth - 400 - player.width)
                    player.y = 200 + love.math.random() * (self.worldHeight - 400 - player.height)

                    -- Use center positions for distance calculation
                    local playerCenterX = player.x + player.collisionBox.offsetX + player.collisionBox.width / 2
                    local playerCenterY = player.y + player.collisionBox.offsetY + player.collisionBox.height / 2
                    local portalCenterX = portal.x + portal.collisionBox.offsetX + portal.collisionBox.width / 2
                    local portalCenterY = portal.y + portal.collisionBox.offsetY + portal.collisionBox.height / 2

                    local dx = playerCenterX - portalCenterX
                    local dy = playerCenterY - portalCenterY
                    local distance = math.sqrt(dx * dx + dy * dy)
                    attempts = attempts + 1
                until distance >= minDistance or attempts >= maxAttempts

                -- Update player position in collision world
                if self.world then
                    self.world:update(
                        player,
                        player.x + player.collisionBox.offsetX,
                        player.y + player.collisionBox.offsetY
                    )
                end
            end
        end
        self.isFirstSpawn = false
    end
end

function overworld:enter(player, transitionData)
    self:initTilemap()
    portal.init()

    -- Reset portal to initial position on first spawn
    if not self.currentUniverse or self.isFirstSpawn then
        portal.x = 1500
        portal.y = 800
    end

    self.world = bump.newWorld(BUMP_CELL_SIZE)

    -- Add entities to world first
    player.addToWorld(self.world)
    portal.addToWorld(self.world)
    self.entities = { player, portal }

    -- Check if we're switching universes from portal interior
    if transitionData.fromRoom == "portal_interior" then
        if transitionData.targetUniverse then
            -- Switch to selected universe (this will randomly place the player)
            self:switchUniverse(transitionData.targetUniverse, player)
            -- Don't override the random placement!
        else
            -- Only place at portal door if NOT changing universe (just exiting)
            player.x = portal.x + portal.interactionZone.x + portal.interactionZone.width / 2 - player.width / 2
            player.y = portal.y + portal.interactionZone.y + portal.interactionZone.height + 10
            -- Update player position in collision world
            if self.world then
                self.world:update(
                    player,
                    player.x + player.collisionBox.offsetX,
                    player.y + player.collisionBox.offsetY
                )
            end
        end
    elseif not self.currentUniverse then
        -- First time entering overworld
        self.currentUniverse = "utopian"
        self.timer = 0
        self.hasLeftUtopianBefore = false
        self.isFirstSpawn = true
    end
    self.worldWidth = self.mapWidth * self.tileSize
    self.worldHeight = self.mapHeight * self.tileSize

    camera.init(player, self.worldWidth, self.worldHeight)
end

function overworld:exit()
    if self.world then
        self.world = nil
    end
end

function overworld:update(dt, player)
    if not self.gameOver then
        player.update(dt, self.worldWidth, self.worldHeight)
        portal.update(dt, player)
    end

    -- Update thought bubble timer
    if self.thoughtTimer > 0 then
        self.thoughtTimer = self.thoughtTimer - dt
    end

    -- Update screen shake
    if self.shakeDuration > 0 then
        self.shakeDuration = self.shakeDuration - dt
        local intensity = self.shakeAmount * (self.shakeDuration / UNIVERSE_SHAKE_DURATION)
        self.shakeOffsetX = (love.math.random() * 2 - 1) * intensity
        self.shakeOffsetY = (love.math.random() * 2 - 1) * intensity
    elseif self.currentUniverse == "dystopian" and not self.gameOver then
        -- Dystopian alternates between calm and fierce shaking
        self.dystopianShakeTimer = self.dystopianShakeTimer - dt
        if self.dystopianShakeTimer <= 0 then
            -- Switch modes
            if self.dystopianShakeMode == "calm" then
                self.dystopianShakeMode = "fierce"
                self.dystopianShakeTimer = 0.5 + love.math.random() * 1.5
            else
                self.dystopianShakeMode = "calm"
                self.dystopianShakeTimer = 1 + love.math.random() * 3
            end
        end

        if self.dystopianShakeMode == "fierce" then
            self.shakeOffsetX = (love.math.random() * 2 - 1) * 15
            self.shakeOffsetY = (love.math.random() * 2 - 1) * 15
        else
            self.shakeOffsetX = 0
            self.shakeOffsetY = 0
        end
    else
        self.shakeOffsetX = 0
        self.shakeOffsetY = 0
    end

    -- Update timer for timed universes
    if self.timer > 0 and not self.gameOver then
        self.timer = self.timer - dt
        if self.timer <= 0 then
            -- Game over!
            self.gameOver = true
            self.timer = 0
        end
    end

    camera.update(player, self.worldWidth, self.worldHeight)
end

local function getSortY(entity)
    if entity.collisionBox then
        return entity.y + entity.collisionBox.offsetY + entity.collisionBox.height
    end
    return entity.y
end

function overworld:draw()
    love.graphics.push()
    love.graphics.translate(self.shakeOffsetX, self.shakeOffsetY)

    camera.apply()
    self:drawTilemap(camera.x, camera.y)

    table.sort(self.entities, function(a, b)
        return getSortY(a) < getSortY(b)
    end)

    for _, entity in ipairs(self.entities) do
        entity.draw()
    end

    love.graphics.pop()

    -- Draw UI (timer, thought bubble, arrows)
    self:drawUI()
end

function overworld:drawDirectionalArrows()
    local room_manager = require("room_manager")
    local player = room_manager.player
    local portal_module = require("entities.portal")
    local portal = portal_module

    if not player or not portal then
        return
    end

    local function getEntityCenter(entity)
        local centerX = entity.x + entity.collisionBox.offsetX + entity.collisionBox.width / 2
        local centerY = entity.y + entity.collisionBox.offsetY + entity.collisionBox.height / 2
        return centerX, centerY
    end

    local function drawArrow(x, y, direction, size)
        if direction == "up" then
            love.graphics.line(x - size, y, x, y - size)
            love.graphics.line(x + size, y, x, y - size)
        elseif direction == "down" then
            love.graphics.line(x - size, y, x, y + size)
            love.graphics.line(x + size, y, x, y + size)
        elseif direction == "left" then
            love.graphics.line(x, y - size, x - size, y)
            love.graphics.line(x, y + size, x - size, y)
        elseif direction == "right" then
            love.graphics.line(x, y - size, x + size, y)
            love.graphics.line(x, y + size, x + size, y)
        end
    end

    local playerX, playerY = getEntityCenter(player)
    local portalX, portalY = getEntityCenter(portal)

    local toPortalX = portalX - playerX
    local toPortalY = portalY - playerY
    local distance = math.sqrt(toPortalX * toPortalX + toPortalY * toPortalY)

    if distance < 300 then
        return
    end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local arrowSize = 30
    local margin = 50

    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.setLineWidth(3)

    if math.abs(toPortalX) > 50 then
        if toPortalX > 0 then
            drawArrow(screenWidth - margin, screenHeight / 2, "right", arrowSize)
        else
            drawArrow(margin, screenHeight / 2, "left", arrowSize)
        end
    end

    if math.abs(toPortalY) > 50 then
        if toPortalY > 0 then
            drawArrow(screenWidth / 2, screenHeight - margin, "down", arrowSize)
        else
            drawArrow(screenWidth / 2, margin, "up", arrowSize)
        end
    end

    -- Reset graphics state
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

function overworld:drawUI()
    love.graphics.push()
    love.graphics.origin()

    -- Game Over screen
    if self.gameOver then
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        -- Dark overlay
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

        -- Game Over text
        local bigFont = love.graphics.newFont(48)
        local oldFont = love.graphics.getFont()
        love.graphics.setFont(bigFont)

        love.graphics.setColor(1, 0.2, 0.2, 1)
        love.graphics.printf("GAME OVER", 0, screenHeight / 2 - 100, screenWidth, "center")

        -- Restart instruction
        local medFont = love.graphics.newFont(24)
        love.graphics.setFont(medFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Press ENTER to restart", 0, screenHeight / 2, screenWidth, "center")

        love.graphics.setFont(oldFont)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.pop()
        return
    end

    -- Timer if active (but no universe label)
    if self.timer > 0 then
        local timerFont = love.graphics.newFont(36)
        local oldFont = love.graphics.getFont()
        love.graphics.setFont(timerFont)
        
        local timerText = string.format("%.1f", self.timer)
        local x, y = 20, 20
        
        -- Draw shadow
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.print(timerText, x + 2, y + 2)
        
        -- Draw timer text
        if self.timer < 5 then
            love.graphics.setColor(1, 0.3, 0.3, 1) -- Red when low
        else
            love.graphics.setColor(1, 1, 1, 1) -- White normally
        end
        love.graphics.print(timerText, x, y)
        
        love.graphics.setFont(oldFont)
    end

    -- Directional arrows
    if not self.gameOver then
        self:drawDirectionalArrows()
    end

    -- Thought bubble (Stardew Valley style - wide, bottom, big font)
    if self.thoughtTimer > 0 then
        local alpha = math.min(1, self.thoughtTimer)
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        -- Create bigger font
        local oldFont = love.graphics.getFont()
        local bigFont = love.graphics.newFont(24)
        love.graphics.setFont(bigFont)

        -- Measure text with bigger font
        local textWidth = bigFont:getWidth(self.currentThought)
        local bubbleWidth = math.min(screenWidth - 100, textWidth + 60)
        local bubbleHeight = 80
        local bubbleX = (screenWidth - bubbleWidth) / 2
        local bubbleY = screenHeight - 150

        -- Draw thought bubble background
        love.graphics.setColor(0, 0, 0, alpha * 0.85)
        love.graphics.rectangle("fill", bubbleX, bubbleY, bubbleWidth, bubbleHeight, 10, 10)

        -- White border
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", bubbleX, bubbleY, bubbleWidth, bubbleHeight, 10, 10)

        -- Draw thought text
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.printf(self.currentThought, bubbleX + 30, bubbleY + 25, bubbleWidth - 60, "center")

        -- Restore original font
        love.graphics.setFont(oldFont)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function overworld:keypressed(key)
    if self.gameOver then
        if key == "return" then
            -- Reset game
            self.gameOver = false
            self.timer = 0
            self.currentUniverse = "utopian"
            self.hasLeftUtopianBefore = false
            self.isFirstSpawn = true
            self.dystopianShakeTimer = 0
            self.dystopianShakeMode = "calm"

            -- Reset player position
            local player = self.entities[1]
            if player then
                player.x = love.graphics.getWidth() / 2 - player.width / 2
                player.y = love.graphics.getHeight() / 2 - player.height / 2
            end

            -- Reset portal to original position
            local portal = self.entities[2]
            if portal and self.world then
                self.world:remove(portal)
                portal.x = 1500
                portal.y = 800
                self.world:add(
                    portal,
                    portal.x + portal.collisionBox.offsetX,
                    portal.y + portal.collisionBox.offsetY,
                    portal.collisionBox.width,
                    portal.collisionBox.height
                )
            end
        end
    elseif key == "x" then
        for _, entity in ipairs(self.entities) do
            if entity.canInteract and entity.onInteract then
                entity.onInteract()
                break
            end
        end
    end
end

function overworld:drawDebug()
    if self.world then
        love.graphics.setColor(1, 0, 0, 0.5)
        local items, len = self.world:getItems()

        for i = 1, len do
            local item = items[i]
            local x, y, w, h = self.world:getRect(item)
            love.graphics.rectangle("line", x, y, w, h)
        end
    end

    love.graphics.setColor(0, 1, 1, 0.3)
    for _, entity in ipairs(self.entities) do
        if entity.interactionZone then
            local x = entity.x + entity.interactionZone.x
            local y = entity.y + entity.interactionZone.y
            local w = entity.interactionZone.width
            local h = entity.interactionZone.height
            love.graphics.rectangle("fill", x, y, w, h)
            love.graphics.setColor(0, 1, 1, 1)
            love.graphics.rectangle("line", x, y, w, h)
            love.graphics.setColor(0, 1, 1, 0.3)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return overworld
