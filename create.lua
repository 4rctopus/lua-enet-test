local create = {}

local universe = require "universe"
local fonts = require "font"

-- filters collisions so the players don't collider
local function playerFilter( item, other )
    if( other.type == "player" or other.type == "bullet" ) then 
        return "cross"
    end
    return "slide"
end

create.player = function( name, home )
    local this = {}
    this.type = "player"
    this.home = home -- true if this is the locally controlled player
    this.name = name -- display name of player
    this.rx, this.ry = 0, 0 -- realx, realy ( from the server )
    this.x, this.y = 0, 0
    this.mx, this.my = 0, 0
    this.speed = 500
    
    -- make a collider for this player
    universe.collisionWorld:add( this, this.x - 50, this.y - 50, 100, 100 )


    this.input = function( this, dt )
        -- get wasd keyboard input
        local mx, my = 0, 0
        if( love.keyboard.isDown( "w" ) ) then
            my = my + -1
        end
        if( love.keyboard.isDown( "a" ) ) then
            mx = mx + -1
        end
        if( love.keyboard.isDown( "s" ) ) then
            my = my + 1
        end
        if( love.keyboard.isDown( "d" ) ) then
            mx = mx + 1
        end

        this.mx, this.my = mx, my
    end

    this.update = function( this, dt )
        if( this.home and not chatOpen ) then
            this:input( dt )
        end


        -- move
        local dx = this.mx * this.speed * dt
        local dy = this.my * this.speed * dt
        local actualX, actualY, cols, len = universe.collisionWorld:move( this, this.x - 50 + dx, this.y - 50 + dy, playerFilter )
        this.x = actualX + 50
        this.y = actualY + 50


        if( not this.home ) then
            -- adjust pos to real pos
            -- if it is moving then rubber band:
            if( this.mx ~= 0 ) then
                this.x = this.x + ( this.rx - this.x ) * dt   
            end
            if( this.my ~= 0 ) then
                this.y = this.y + ( this.ry - this.y ) * dt   
            end         
            -- if it is not moving then move it towards where it should be with it's normal speed
            if( this.mx == 0 and this.my == 0 ) then
                if( this.x > this.rx ) then
                    this.x = this.x - this.speed * dt
                    if( this.x < this.rx ) then this.x = this.rx end
                elseif( this.x < this.rx ) then
                    this.x = this.x + this.speed * dt
                    if( this.x > this.rx ) then this.x = this.rx end
                end

                if(  this.y > this.ry ) then
                    this.y = this.y - this.speed * dt
                    if( this.y < this.ry ) then this.y = this.ry end
                elseif(  this.y < this.ry ) then
                    this.y = this.y + this.speed * dt
                    if( this.y > this.ry ) then this.y = this.ry end
                end
            end

            -- if it is really far from where it should be then teleport it there
            if( math.abs( this.rx - this.x ) > 50 ) then
                this.x = this.rx
            end
            if( math.abs( this.ry - this.y ) > 50 ) then
                this.y = this.ry
            end
            -- update collider to adjusted position
            universe.collisionWorld:update( this, this.x - 50, this.y - 50 )
        end


        if( this.home ) then
            -- set camera center to player
            universe.camera.x, universe.camera.y = this.x, this.y
        end
    end

    this.draw = function( this )
        local w = 100
        love.graphics.setColor( 0, 0.7, 0.1 )
        love.graphics.rectangle( "fill", this.x - w / 2, this.y - w / 2, w, w )

        -- display the name of this player
        love.graphics.setColor( 1, 1, 1 )
        love.graphics.setFont( fonts.cfont24 );
        if( this.name ) then
            love.graphics.printf( this.name, this.x - w / 2 - 50, this.y - w / 2 - 50, w + 100, "center" )
        end
    end

    this.clear = function( this )
        -- remove this player's collider from the world
        universe.collisionWorld:remove( this )
    end

    this.mousepressed = function( this, x, y )
        if( this.home )then
            -- shoot a bullet
            local mx, my = love.mouse.getX(), love.mouse.getY()
            -- transform point from screenpos to globalpos
            mx, my = universe.camera:inverseTransformPoint( mx, my ) 
            -- get rotation of the bullet
            local rot = math.atan2( ( my - this.y ) , ( mx - this.x ) )
            -- add a rando angle to it for inaccuracy
            rot = rot + love.math.random( ) / 5 - 0.2 /2
            local bullet = create.bullet( this.x, this.y, rot, this.id )
            universe.bullets[bullet] = bullet
        end
    end
    
    return this 
end


create.wall = function( x, y, w, h )
    local this = {}
    this.type = "wall"

    universe.collisionWorld:add( this, x, y, w, h )

    return this
end

local function bulletFilter( item, other )
    -- bullets only collide with walls for now
    if( other.type == "wall" ) then return "touch" end
    return "cross"
end

create.bullet = function( x, y, rot, id )
    local this = {}
    this.type = "bullet"

    -- send the bullet creation info to server if it was created locally on a client
    if( serverpeer and id == clientId ) then
        serverpeer:send( "bul " .. id .. " " .. x .. " " .. y .. " " .. rot .. " " )
    -- if this is on the server then send it to every client ( shouldn't send it to the client where we got it from but whatever )
    elseif( host ) then 
        host:broadcast( "bul " .. id .. " " .. x .. " " .. y .. " " .. rot .. " " )
    end

    -- owner player's id
    this.playerid = id

    this.x = x
    this.y = y
    this.speed = 2000
    -- vx, vy from the rotation
    this.vx = math.cos( rot ) * this.speed
    this.vy = math.sin( rot ) * this.speed

    -- max lifetime( if it doesn't collide ) of the bullet
    this.time = 10

    -- make a collider for it
    universe.collisionWorld:add( this, this.x, this.y, 1, 1 )

    this.draw = function( this )
        love.graphics.setColor( 0, 1, 0.5 )
        love.graphics.circle( "fill", this.x, this.y, 15 )
    end

    this.update = function( this, dt )
        local dx = this.vx * dt
        local dy = this.vy * dt
        local actualX, actualY, cols, len = universe.collisionWorld:move( this, this.x + dx, this.y + dy, bulletFilter )
        this.x = actualX
        this.y = actualY

        for i, col in pairs( cols ) do
            if( col.other.type == "wall" )then
                -- remove bullet's collider and bullet if it touched a wall
                universe.collisionWorld:remove( this )
                universe.bullets[this] = nil
                return
            end
        end

        this.time = this.time - dt
        if( this.time < 0 ) then
            -- remove bullet's collider and bullet if it touched a wall
            universe.collisionWorld:remove( this )
            universe.bullets[this] = nil
        end
    end

    return this
end

return create