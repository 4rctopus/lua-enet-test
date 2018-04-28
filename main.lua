lovecallbacks = {
    "load",
    "update",
    "draw",

    "mousepressed",
    "mousereleased",
    "mousemoved",
    "wheelmoved",
    "keypressed",
    "keyreleased",
    "textinput",
    "textedited",
    "touchmoved",
    "touchpressed",
    "touchreleased",

    "resize",
    "focus",
    "quit",
    "filedropped",
}

--[[
local tab = { 1, 2, 3, 4, 5, 6 }
print( #tab )
tab[3] = nil
print( #tab )
for i, val in pairs( tab ) do
    print( i, val )
end
--]]




local startState = require "start"
require "ui/ui"
local events = require "event"
local fonts = require "font"


function loadState( newState, arg )
    state = newState
    if( state.load ) then state.load( arg ) end
end

-- set up callbacks
for _, callback in pairs( lovecallbacks ) do
    love[callback] = function( arg1, arg2, arg3, arg4, arg5, arg6 )
        if( state[callback] ) then state[callback]( arg1, arg2, arg3, arg4, arg5, arg6 ) end
        events.callback( callback, arg1, arg2, arg3, arg4, arg5, arg6 )
    end
end

function love.load()
    loadState( startState )
    fonts.resize( love.graphics.getWidth(), love.graphics.getHeight() )
    ui.init()
end

function love.update( dt )
    if( state.update ) then state.update( dt ) end
    gDt = dt
end

function love.draw()
    if( state.draw ) then state.draw() end


    

    love.graphics.origin()
    love.graphics.setColor( 1,1, 1 )
    local stats = love.graphics.getStats()
    love.graphics.print( love.timer.getFPS() .. "\n" ..
                         "draws: " .. stats.drawcalls .. "\n" ..
                         "tmem: " .. stats.texturememory / 1024 / 1024 .. " mb" .. "\n"  )
    
    ui.reset()
    events.reset()
end

function love.resize(w, h)
    if( state.resize ) then state.resize( w, h ) end
    events.callback( "resize", w, h )

    -- change font size
    fonts.resize( w, h )
end