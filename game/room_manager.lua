local room_manager = {}

local FADE_SPEED = 2

room_manager.current = nil
room_manager.rooms = {}
room_manager.fadeAlpha = 0
room_manager.fadeState = nil
room_manager.nextRoom = nil
room_manager.player = nil

function room_manager.init(player)
    room_manager.player = player
end

function room_manager.register(name, room)
    room_manager.rooms[name] = room
end

function room_manager.switch(targetRoomName, transitionData)
    if not room_manager.rooms[targetRoomName] then
        error("Room '" .. targetRoomName .. "' not registered")
    end

    room_manager.fadeState = "out"
    room_manager.nextRoom = targetRoomName
    room_manager.transitionData = transitionData or {}
end

function room_manager.completeTransition()
    if room_manager.current and room_manager.current.exit then
        room_manager.current:exit()
    end

    room_manager.current = room_manager.rooms[room_manager.nextRoom]

    if room_manager.current.enter then
        room_manager.current:enter(room_manager.player, room_manager.transitionData)
    end

    room_manager.fadeState = "in"
end

function room_manager.update(dt)
    if room_manager.fadeState == "out" then
        room_manager.fadeAlpha = math.min(1, room_manager.fadeAlpha + dt * FADE_SPEED)
        if room_manager.fadeAlpha >= 1 then
            room_manager.completeTransition()
        end
    elseif room_manager.fadeState == "in" then
        room_manager.fadeAlpha = math.max(0, room_manager.fadeAlpha - dt * FADE_SPEED)
        if room_manager.fadeAlpha <= 0 then
            room_manager.fadeState = nil
        end
    end

    if not room_manager.fadeState and room_manager.current and room_manager.current.update then
        room_manager.current:update(dt, room_manager.player)
    end
end

function room_manager.draw()
    if room_manager.current and room_manager.current.draw then
        room_manager.current:draw()
    end

    if room_manager.fadeAlpha > 0 then
        love.graphics.origin()
        love.graphics.setColor(0, 0, 0, room_manager.fadeAlpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function room_manager.keypressed(key)
    if not room_manager.fadeState and room_manager.current and room_manager.current.keypressed then
        room_manager.current:keypressed(key)
    end
end

return room_manager
