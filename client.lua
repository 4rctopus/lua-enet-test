local clientState = {}

local enet = require "enet"
local universe = require "universe"
local create = require "create"


local host
local server

local clientName 



function clientState.load( ip, name )
    host = enet.host_create()
    server = host:connect( ip )

    universe.load()

    clientId = nil
    serverpeer = nil
    clientName = name
end



function decod( data )
    local res = {}
    local spos = string.find( data, " " )
    local lpos = 1
    while( spos ) do
        res[#res + 1] = string.sub( data, lpos, spos - 1 )
        lpos = spos + 1
        spos = string.find( data, " ", spos + 1 ) 
    end

    return res
end

time = 0

function clientState.update( dt )
    time = time - dt

    local event = host:service()
    while event do
        if event.type == "receive" then
            local data = decod( event.data )

            -- ONCE
            if( data[1] == "id" ) then
                -- got our id, and other player ids
                local id = tonumber( data[2] )
                
                local i = 3
                while( data[i] ) do
                    universe.players[tonumber(data[i])] = create.player()
                    i = i + 1
                end

                universe.players[id] = create.player( clientName, true )
                clientId = id
            end

            -- ONCE
            if( data[1] == "names" )then
                -- get names:
                local i = 2
                while( data[i] ) do
                    local id = tonumber( data[i] )
                    universe.players[id].name = data[i + 1]
                    i = i + 2
                end
            end

            -- ONCE
            if( data[1] == "add" ) then
                -- new player joined
                local id = tonumber( data[2] )
                if( not universe.players[id] ) then
                    universe.players[id] = create.player()
                end
            end

            -- ONCE
            if( data[1] == "remove" ) then
                local id = tonumber( data[2] )
                if( universe.players[id] ) then
                    universe.players[id]:clear()
                    universe.players[id] = nil
                end
            end


            -- ONCE
            -- bullet
            if( data[1] == "bul" )then
                local id = tonumber( data[2] )
                if( id ~= clientId ) then
                    local bullet = create.bullet( tonumber( data[3] ), tonumber( data[4] ), tonumber( data[5] ), id )
                    universe.bullets[bullet] = bullet
                end
            end

            -- SYNC
            if( data[1] == "pos" ) then
                local id = tonumber( data[2] )
                if( universe.players[id] and not universe.players[id].home ) then
                    universe.players[id].rx = tonumber( data[3] )
                    universe.players[id].ry = tonumber( data[4] )
                    universe.players[id].mx = tonumber( data[5] ) 
                    universe.players[id].my = tonumber( data[6] )
                end
            end

        elseif event.type == "connect" then
            print(event.peer, "connected.")
            serverpeer = event.peer
            -- ONCE
            -- send name
            serverpeer:send( "name " .. clientName .. " " )

        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
            -- reset stuff if we get disconnected
            for i, player in pairs( universe.players ) do
                player:clear()
            end
            universe.players = {}
            -- and go back to start state
            state = require "start"
        end
        event = host:service()
    end

    
    -- SYNC
    -- send our players data
    if( serverpeer and clientId and time < 0 ) then
        local x, y, mx, my = universe.players[clientId].x, universe.players[clientId].y, universe.players[clientId].mx, universe.players[clientId].my
        serverpeer:send( "pos " .. x .. " " .. y .. " " .. mx .. " " .. my .. " " , 0, "unreliable" )
    end


    universe.update( dt )

    if( time < 0 ) then time = 0.07 end
end

function clientState.draw()
    universe.draw()
end

function clientState.mousepressed( x, y )
    universe.mousepressed( x, y )
end

return clientState