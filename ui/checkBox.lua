local lume = require "lib/lume"
local event = require "event"

ui.checkBoxSettings = {
    name = "noname", x = 0, y = 0, w = 100, h = 100, checked = false,
    hoverColor = { 37 / 255, 41 / 255, 49 / 255 },
    color = { 33 / 255, 37 / 255, 43 / 255 },
}

-- checkBox
function ui.checkBox( settings )
    local state = {}
    local s = lume.merge( ui.checkBoxSettings, settings )

    -- add this checkbox to the elements if it isn't htere yet
    if( ui.elements[s.name] == nil ) then
        ui.elements[s.name] = {}
        ui.elements[s.name].checked = false
    end
    if( s.checked ~= nil ) then
        ui.elements[s.name].checked = s.checked
    end

    -- event input
    if( ui.enableInput ) then
        for i, input in ipairs( event.mousereleased ) do
            if( pointInsideRectangle( input.x, input.y, s.x, s.y, s.w, s.h ) ) then
                ui.elements[name].checked = not ui.elements[name].checked
            end
        end
    end

    -- draw outline rectangle
    if( mouseOver( s.x, s.y, s.w, s.h ) ) then
        if( ui.enableInput ) then
        love.graphics.setColor( s.hoverColor  )
        end
    else
        love.graphics.setColor( s.color )
    end

    love.graphics.rectangle("line", s.x, s.y, s.w, s.h )

    -- draw checked rectangle
    if( ui.elements[name].checked ) then
        love.graphics.setColor( s.color )
        love.graphics.rectangle("fill", s.x + 5, s.y + 5, s.w - 10, s.h - 10 )
    end


    state.checked = ui.elements[name].checked
    return state
end
