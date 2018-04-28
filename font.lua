local fonts = {}


function fonts.resize( x, y )
    local fthing = 1 / 900 * love.graphics.getHeight()

    -- default
    fonts.cdefault = love.graphics.newFont( 14 )

    fonts.rfont24 = love.graphics.newFont( "files/font.ttf", 16 * fthing )
    fonts.rfont80 = love.graphics.newFont( "files/font.ttf", 40 * fthing )

    -- constants
    fonts.cfont24 = love.graphics.newFont( "files/font.ttf", 18 ) -- makes perfect sense
    fonts.cfont80 = love.graphics.newFont( "files/font.ttf", 80 )
end

return fonts
