local universe = {}

local create 
local bump = require "lib/bump"
local fonts = require "font"
local camera = require "camera"

universe.players = {}
universe.walls = {}
universe.bullets = {}

universe.collisionWorld = bump.newWorld()

universe.camera = camera.create()

chatOpen = false
local chatTextBox = false
chatTexts = {}



function universe.load()
    create = require "create"
    universe.walls[#universe.walls + 1] = create.wall( -200, -200, 300, 50 )
    universe.walls[#universe.walls + 1] = create.wall(-200, 300, 300, 50 )
    universe.walls[#universe.walls + 1] = create.wall( 300, -200, 50, 500 )
    universe.walls[#universe.walls + 1] = create.wall( -200, -50, 50, 50 )
end

function universe.update( dt )
    for i, player in pairs( universe.players ) do
        player.id = i
        player:update( dt )
    end
    for i, bullet in pairs( universe.bullets ) do
        bullet:update( dt )
    end
end

function universe.draw()
    universe.camera:set()

    for _, player in pairs( universe.players ) do
        player:draw()
    end
    for _, bullet in pairs( universe.bullets ) do
        bullet:draw()
    end

    for _, wall in pairs( universe.walls ) do
        local x, y, w, h = universe.collisionWorld:getRect( wall )
        love.graphics.setColor( 1, 1, 1 )
        love.graphics.rectangle( "fill", x, y, w, h )
    end

    --[[
    local items, len = universe.collisionWorld:getItems()
    for i, item in pairs( items ) do
        local x, y, w, h = universe.collisionWorld:getRect( item )
        love.graphics.setColor( 1, 0, 0 )
        love.graphics.rectangle( "line", x, y, w, h  )
    end
    --]]

    love.graphics.origin()

    local cfont = fonts.cfont24

    love.graphics.setFont( cfont )
    local y = 100
    for i = math.max( 1, #chatTexts - 10 ), #chatTexts do
        love.graphics.print( chatTexts[i], 10, y )
        y = y + cfont:getHeight() + 10
    end

    -- chat textbox
    if( chatOpen ) then
        local p = 20; -- push
        local h = cfont:getHeight();
        chatTextBox = ui.textBox( { name = "chat", font = cfont, x = p, y = love.graphics.getHeight() - h - p, w = love.graphics.getWidth() - 2 * p, noChangeText = true, autoFocus = true  } );
    end
end

function universe.mousepressed( x, y )
    for _, player in pairs( universe.players ) do
        player:mousepressed( x, y )
    end
end

function universe.keypressed( key )
    if( key == "return" ) then
        if( chatOpen ) then
            chatOpen = false;
            if( chatTextBox.text ~= "" ) then
                if( serverpeer ) then
                    serverpeer:send( "chat " ..  chatTextBox.text .. " " );
                elseif( host ) then
                    host:broadcast( "chat " .. universe.players[clientId].name .. " " .. chatTextBox.text .. " " );
                    chatTexts[#chatTexts + 1] = universe.players[clientId].name .. ": " .. chatTextBox.text;
                end
            end
            ui.clear()
        else
            chatOpen = true;
        end
    end
end

return universe
