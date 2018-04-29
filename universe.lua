local universe = {}

local create 
local bump = require "lib/bump"

local camera = require "camera"

universe.players = {}
universe.walls = {}
universe.bullets = {}

universe.collisionWorld = bump.newWorld()


universe.camera = camera.create()


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

    ---[[
    local items, len = universe.collisionWorld:getItems()
    for i, item in pairs( items ) do
        local x, y, w, h = universe.collisionWorld:getRect( item )
        love.graphics.setColor( 1, 0, 0 )
        love.graphics.rectangle( "line", x, y, w, h  )
    end
    --]]
end

function universe.mousepressed( x, y )
    for _, player in pairs( universe.players ) do
        player:mousepressed( x, y )
    end
end

return universe
