local create = {}

local universe = require "universe"


create.player = function( name, home )
    local this = {}
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
            if( this.mx ~= 0 or this.my ~= 0 ) then
                this.x = this.x + ( this.rx - this.x ) * dt   
                this.y = this.y + ( this.ry - this.y ) * dt            
            else
                if( math.abs( this.x - this.rx ) > 5 ) then
                    this.x = this.rx
                end
                if( math.abs( this.y - this.ry ) > 5 ) then
                    this.y = this.ry
                end
            end
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

    return this 
end


create.wall = function( x, y, w, h )
    local this = {}

    universe.collisionWorld:add( this, x, y, w, h )

    return this
end

return create