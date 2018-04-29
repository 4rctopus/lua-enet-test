local create = {}

local universe = require "universe"


create.player = function( name, home )
    local this = {}
    this.type = "player"
    this.home = home
    this.name = name
    this.rx, this.ry = 0, 0 -- realx, realy ( from the server )
    this.x, this.y = 0, 0
    this.mx, this.my = 0, 0
    this.speed = 500

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
        if( this.home ) then
            this:input( dt )
        end

        --if( type( this.mx ) ~= "number" ) th

        -- move
        local dx = this.mx * this.speed * dt
        local dy = this.my * this.speed * dt
        local actualX, actualY, cols, len = universe.collisionWorld:move( this, this.x - 50 + dx, this.y - 50 + dy )
        this.x = actualX + 50
        this.y = actualY + 50


        if( not this.home ) then
            -- adjust pos to real pos
            ---[[
            if( this.mx ~= 0 ) then
                this.x = this.x + ( this.rx - this.x ) * dt   
            end
            if( this.my ~= 0 ) then
                this.y = this.y + ( this.ry - this.y ) * dt   
            end         
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

            if( math.abs( this.rx - this.x ) > 50 ) then
                this.x = this.rx
            end

            --]]
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

        love.graphics.setColor( 1, 1, 1 )
        if( this.name ) then
            love.graphics.printf( this.name, this.x - w / 2 - 50, this.y - w / 2 - 50, w + 100, "center" )
        end
    end

    this.clear = function( this )
        universe.collisionWorld:remove( this )
    end

    this.mousepressed = function( this, x, y )
        if( this.home )then
            local mx, my = love.mouse.getX(), love.mouse.getY()
            mx, my = universe.camera:inverseTransformPoint( mx, my )
            local rot = math.atan2( ( my - this.y ) , ( mx - this.x ) )
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

create.bullet = function( x, y, rot, id )
    local this = {}

    if( serverpeer and id == clientId ) then
        serverpeer:send( "bul " .. id .. " " .. x .. " " .. y .. " " .. rot .. " " )
    elseif( host ) then 
        host:broadcast( "bul " .. id .. " " .. x .. " " .. y .. " " .. rot .. " " )
    end

    this.playerid = id

    this.x = x
    this.y = y
    this.speed = 1000
    this.vx = math.cos( rot ) * this.speed
    this.vy = math.sin( rot ) * this.speed

    this.time = 10

    this.draw = function( this )
        --love.graphics.setColor( 0, 255, 0 )
        love.graphics.setColor( 0, 1, 0.5 )
        love.graphics.circle( "fill", this.x, this.y, 15 )
    end

    this.update = function( this, dt )
        this.x = this.x + this.vx * dt
        this.y = this.y + this.vy * dt

        local items, len = universe.collisionWorld:queryPoint( this.x, this.y )
        for i, item in pairs( items ) do
            if( item.type == "wall" )then
                universe.bullets[this] = nil
                return
            end
        end

        this.time = this.time - dt
        if( this.time < 0 ) then
            universe.bullets[this] = nil
        end
    end

    return this
end

return create