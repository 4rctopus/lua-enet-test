local lume = require "lib/lume"
local event = require "event"

ui.sliderSettings = {
    name = "noname", x = 0, y = 0, w = 100, h = 100, value = 0, noChangeValue = false,
    hoverColor = { 37 / 255, 41 / 255, 49 / 255 },
    downColor = { 44 / 255, 49 / 255, 58 / 255 },
    color = { 33 / 255, 37 / 255, 43 / 255 },
    grabColor = { 63 / 255, 81 / 255, 181 / 255 },
    grabColorDown = {106 / 255, 27 / 255, 154 / 255 },
}

--function ui.slider( name, x, y, w, h, value, noChangeValue )
function ui.slider( settings )
    local state = {}
    local s = lume.merge( ui.sliderSettings, settings )

    -- add this slider to elements
    local element
    if( ui.elements[s.name] == nil ) then
        ui.elements[s.name] = {}
        ui.elements[s.name].value = 0.5
        ui.elements[s.name].grabbed = false
        if( s.value ~= nil ) then
            ui.elements[s.name].value = s.value
        end
    end
    element = ui.elements[s.name]
    if( s.noChangeValue ~= true ) then
        element.value = s.value
    end



    -- position of the slider line
    local sx = s.x
    local sy = s.y
    -- position of the slider grab
    local hPush = 3 -- space above and below the grab
    local grabWidth = s.w / 13 -- this one makes the grab smaller/ bigger
    local grabHeight = s.h - hPush * 2;
    -- the interval in which we can actually move the slider )
    local slideWidth = s.w - 2 * ( grabWidth / 2 + hPush )
    local slidex = sx + hPush + grabWidth / 2

    local grabsx = slidex + element.value * slideWidth - grabWidth / 2
    local grabsy = s.y + hPush

    -- event input
    if( ui.enableInput ) then
        for i, input in ipairs( event.mousepressed ) do
            if( pointInsideRectangle( input.x, input.y, sx, sy, s.w, s.h ) ) then
                element.grabbed = true
                element.value = ( input.x - slidex ) / slideWidth
            end
        end
        for i, input in ipairs( event.mousereleased ) do
            element.grabbed = false
        end
        for i, input in ipairs( event["mousemoved"] ) do
            if( element.grabbed and input.x < sx + s.w and input.x > sx ) then
                element.value = element.value + input.dx / slideWidth
            end
        end
    end

    if( element.value < 0 ) then element.value = 0 end
    if( element.value > 1 ) then element.value = 1 end
    local grabsx = slidex + element.value * slideWidth - grabWidth / 2


    -- draw line of slider
    love.graphics.setColor( s.color  )
    love.graphics.rectangle("fill", sx, sy, s.w, s.h )



    love.graphics.setColor( s.grabColor )
    if( element.grabbed ) then
        love.graphics.setColor( s.grabColorDown )
    end
    love.graphics.rectangle( "fill", grabsx, grabsy, grabWidth, grabHeight )


    state.value = element.value
    return state
end
