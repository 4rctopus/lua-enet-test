local lume = require "lib/lume"
local utf8 = require 'utf8'
local event = require "event"

local function split(str, pos)
	local offset = utf8.offset(str, pos) or 0
	return str:sub(1, offset-1), str:sub(offset)
end

ui.textBoxSettings = {
    name = "noname", x = 0, y = 0, w = 100, font = nil, text = "", noChangeText = false, autoFocus = false,
    backgroundColor = { 44 / 255, 49 / 255, 58 / 255 },
    cursorColor = {  58 / 255, 139 / 255, 255 / 255 },
}


--function ui.textBox( name, x, y, w, font, text, noChangeText )
function ui.textBox( settings )
    local state = {}
    local s = lume.merge( ui.textBoxSettings, settings )
    h = s.font:getHeight()
    -- add this slider to elements
    if( ui.elements[s.name] == nil ) then
        ui.elements[s.name] = {}
        ui.elements[s.name].text = ""
        ui.elements[s.name].textx = x
        ui.elements[s.name].focused = s.autoFocus
        ui.elements[s.name].cursorPos = 1
        if( s.text ~= nil ) then
            ui.elements[s.name].text = s.text
        end
    end
    local element = ui.elements[s.name]
	if( s.noChangeText == false ) then
		element.text = s.text
	end

    local xPush = 3
    local textx = s.x

    local a, b = split( element.text, element.cursorPos )
    local cx = textx + xPush + s.font:getWidth( a .. "W" )
    if( cx >= s.x + s.w ) then
        textx = textx - ( cx - ( s.x + s.w ) )
    elseif( cx - s.font:getWidth( "W" ) <= s.x ) then
        textx = textx + ( s.x - ( cx - s.font:getWidth( "W" ) ) ) + xPush
    end

    --element.textx = textx
    if( ui.enableInput ) then
        -- mousepressed
        for i, input in ipairs( event.mousepressed ) do
            if( pointInsideRectangle( input.x, input.y, s.x, s.y, s.w, h ) ) then
                element.focused = true
                -- set cursor position
                local rightOfText = true
                local mx = input.x - ( textx + xPush )
                for c = 1, string.len( element.text ) + 1 do
                    local sub = element.text:sub( 0, utf8.offset( element.text, c) - 1 )
                    if( s.font:getWidth( sub ) >= mx ) then
                        element.cursorPos = c - 1
                        rightOfText = false
                        break
                    end
                end
                if( rightOfText ) then
                    element.cursorPos = string.len( element.text ) + 1
                end
            else
                element.focused = false
            end   
        end
        if( element.focused ) then
            -- textinput
            for i, input in ipairs( event.textinput ) do    
                -- add input.text to element.text at element.cursosPos
                local a, b = split( element.text, element.cursorPos )
                element.text = a .. input.text .. b
                element.cursorPos = element.cursorPos + utf8.len( input.text )
            end
            -- mousemoved
            for i, input in ipairs( event.mousemoved ) do 
                if( love.mouse.isDown( 1 ) ) then
                    local mx = input.x + input.dx
                    local rightOfText = true
                    local mx = mx - ( textx + xPush )
                    for c = 1, string.len( element.text ) + 1 do
                        local sub = element.text:sub( 0, utf8.offset( element.text, c) - 1 )
                        if( s.font:getWidth( sub ) >= mx ) then
                            element.cursorPos = c - 1
                            rightOfText = false
                            break
                        end
                    end
                    if( rightOfText ) then
                        element.cursorPos = string.len( element.text ) + 1
                    end
                end
            end
            -- keypressed
            for i, input in ipairs( event.keypressed ) do
                if( input.key == "backspace" and element.cursorPos > 0 ) then
                    -- remove a character from element.text at element.cursorPos
                    local a, b = split( element.text, element.cursorPos )
                    element.text = split( a, utf8.len( a ) ) .. b
                    element.cursorPos = math.max( element.cursorPos - 1, 1 )
                end
                if( input.key == "home" ) then
                    element.cursorPos = 1
                end
                if( input.key == "end" ) then
                    element.cursorPos = string.len( element.text ) + 1
                end
                if( input.key == "right" ) then
                    element.cursorPos = math.min( element.cursorPos + 1, string.len( element.text ) + 1 )
                end
                if( input.key == "left" ) then
                    element.cursorPos = math.max( element.cursorPos - 1, 1 )
                end
            end
        end
    end
    -- draw background rectangle
    love.graphics.setColor( s.backgroundColor )
    love.graphics.rectangle("fill", s.x, s.y, s.w, h )

    -- draw text
    love.graphics.setScissor( s.x + xPush, s.y, s.w - 2 * xPush, h )
    love.graphics.setFont( s.font )
    love.graphics.setColor( 255, 255, 255, 255 )
    love.graphics.print( element.text, textx + xPush, s.y )

    -- draw blinking thingy
    if( ui.enableInput ) then
    if( element.focused and ui.cursorBlinkTime > 0.5 ) then
        love.graphics.setColor( s.cursorColor )
        local a, b = split( element.text, element.cursorPos )
        local cx = textx + xPush + s.font:getWidth( a )
        love.graphics.rectangle("fill", cx, s.y, 2, h )
    end
    end
    love.graphics.setScissor( )


    state.text = element.text
    return state
end
