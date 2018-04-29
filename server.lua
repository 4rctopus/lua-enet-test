local serverState = {}

local enet = require "enet"

local universe = require "universe"
local create = require "create"



host = nil

local peers = {}

function serverState.load( ip, name )
    host = enet.host_create( ip )

    universe.load()
    universe.players[1] = create.player( name, true )
end


time = 0
function serverState.update( dt )
    time = time - dt

    local event = host:service()
    while event do
        if event.type == "receive" then
            local data = decod( event.data )


            -- ONCE
            -- got a name from a client
            if( data[1] == "name" ) then
                universe.players[peers[event.peer].playerid].name = data[2]

                local players = "names "
                for i, player in pairs( universe.players ) do
                    players = players .. i .. " " .. player.name .. " "
                end
                -- broadcast names:
                -- ONCE
                host:broadcast( players )
            end

            -- ONCE
            -- bullet
            if( data[1] == "bul" ) then
                local bullet = create.bullet( tonumber( data[3] ), tonumber( data[4] ), tonumber( data[5] ), tonumber( data[2] ) )
                universe.bullets[bullet] = bullet
            end

            -- SYNC
            -- got a pos data from a client
            if( data[1] == "pos" ) then
                local id = peers[event.peer].playerid
                universe.players[id].rx = tonumber( data[2] )
                universe.players[id].ry = tonumber( data[3] )
                universe.players[id].mx = tonumber( data[4] ) 
                universe.players[id].my = tonumber( data[5] )
            end
             


        elseif event.type == "connect" then
            print(event.peer, "connected.")
            peers[event.peer] = {}
            peers[event.peer].playerid = #universe.players + 1
            local id = peers[event.peer].playerid
            -- send players' id
            local players = "id " .. id .. " "
            for i, player in pairs( universe.players ) do
                players = players .. i .. " "
            end
            event.peer:send( players )

            universe.players[id] = create.player()
            universe.players[id].peer = event.peer
            
            -- broadcast add
            host:broadcast( "add" .. " " .. id .. " " )

        elseif event.type == "disconnect" then
            print(event.peer, "disconnected.")
            universe.players[peers[event.peer].playerid]:clear()
            universe.players[peers[event.peer].playerid] = nil

            -- ONCE
            -- broadcast removal
            host:broadcast( "remove " .. peers[event.peer].playerid .. " " )
        end
        event = host:service()
    end


    universe.update( dt )

    -- SYNC
    if( time < 0 )then
        -- send all players' data to every client
        for i, player in pairs( universe.players ) do
            host:broadcast( "pos " .. i .. " " .. player.x .. " " .. player.y .. " " .. player.mx .. " " .. player.my .. " " , 0, "unreliable" )
        end
    end


    if( time < 0 ) then time = 0.05 end
end

function serverState.draw()
    universe.draw()
end

function serverState.mousepressed( x, y )
    universe.mousepressed( x, y )
end

return serverState