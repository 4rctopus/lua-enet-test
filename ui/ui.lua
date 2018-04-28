ui = {}


require "ui/button"
require "ui/slider"
require "ui/checkBox"
require "ui/textBox"


function mouseOver( x, y, w, h )
    local mx = love.mouse.getX()
    local my = love.mouse.getY()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function pointInsideRectangle( mx, my, x, y, w, h )
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function setColor( color, r, g, b, a )
    if( a == nil ) then a = 255 end
    color.r, color.g, color.b, color.a = r, g, b, a
end


function colorTorgb( color )
    return color.r, color.g, color.b, color.a
end


function ui.init()
    ui.elements = {}

    ui.cursorBlinkTime = 1
    ui.enableInput = true
    ui.input = {}
end

function ui.clear()
    ui.elements = {}
end
function ui.reset()
    ui.input = {}
    ui.cursorBlinkTime = ui.cursorBlinkTime - gDt
    if( ui.cursorBlinkTime < 0 ) then ui.cursorBlinkTime = 1 end
end

-- Button +
-- TextButton +
-- Check Box +
-- Slider +
-- TextBox +
-- Scrollable canvas thingy - don't need it
