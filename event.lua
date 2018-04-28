local event = {}

function event.reset()
    for i, callback in ipairs( lovecallbacks ) do
        event[callback] = {}
    end
end
event.reset()

local callbackvars = {
    load = { "arg" },
    update = { "dt" },
    draw = {},

    mousepressed = { "x", "y", "button", "istouch" },
    mousereleased = { "x", "y", "button", "istouch" },
    mousemoved = { "x", "y", "dx", "dy", "istouch" },
    wheelmoved = { "x", "y" },
    keypressed = { "key", "scancode", "isrepeat" },
    keyreleased = { "key", "scancode" },
    textinput = { "text" },
    textedited = { "text", "start", "length" },
    touchmoved = { "id", "x", "y", "dx", "dy", "pressure" },
    touchpressed = { "id", "x", "y", "dx", "dy", "pressure" },
    touchreleased = { "id", "x", "y", "dx", "dy", "pressure" },

    resize = { "w", "h" },
    focus = { "focus" },
    filedropped =  { "file" },
}

function event.callback( callback, ... )
    local e = {}
    if( callbackvars[callback] ) then
    for i, var in ipairs( callbackvars[callback] ) do
        e[var] = select( i, ... )
    end end
    table.insert( event[callback], e )
end


return event