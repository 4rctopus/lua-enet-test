local camera = {}

function camera.create( name )
    local this = {}
    this.name = name or nil

    --
    this.ox = 0
    this.oy = 0
    this.x = 0
    this.y = 0
    this.sx = 1
    this.sy = 1
    this.rot = 0


    this.set = function( this )
        love.graphics.origin()

        love.graphics.scale( this.sx, this.sy )
        
        love.graphics.translate( love.graphics.getWidth() / this.sx / 2,
                             love.graphics.getHeight() / this.sy / 2  ) 
        
    
        love.graphics.translate( -this.x, -this.y )

        love.graphics.translate( this.ox, this.oy )
        love.graphics.rotate( this.rot )    
        love.graphics.translate( -this.ox, -this.oy )    
    end

    
    this.transformPoint = function( this, x, y )
        love.graphics.push()
        this:set()

        local sx, sy = love.graphics.transformPoint( x, y )

        love.graphics.pop()

        return sx, sy
    end

    this.inverseTransformPoint = function( this, x, y )
        love.graphics.push()
        this:set()

        local sx, sy = love.graphics.inverseTransformPoint( x, y )

        love.graphics.pop()

        return sx, sy
    end

    this.move = function( this, x, y )
        this.x = this.x + x
        this.y = this.y + y
    end

    return this
end

return camera