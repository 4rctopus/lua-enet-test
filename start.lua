local startState = {}

local serverState = require "server"
local clientState = require "client"


local fonts = require "font"
local lume = require "lib/lume"


function startState.draw()
    local textcfg = { w = love.graphics.getWidth() * 0.3, font = fonts.rfont80, noChangeText = true,
         }
    ui.buttonSettings = lume.merge( ui.buttonSettings, { font = fonts.rfont80, 
        w = textcfg.font:getWidth("WWWWWW"), h = textcfg.font:getHeight() * 1.2 } )

    local hostName = ui.textBox( lume.merge( textcfg, { name = "hostName", text = "serverr",
        y = love.graphics.getHeight() / 3 - textcfg.font:getHeight() * 1.2 - 10, x = love.graphics.getWidth() * 0.03  } ) )
    local hostText = ui.textBox( lume.merge( textcfg, { name = "hostText", text = "localhost:6789",
        y = love.graphics.getHeight() / 3, x = love.graphics.getWidth() * 0.03  } ) )

    
    local hostButton = ui.button( { name = "hostButton", text = "host", 
        x = love.graphics.getWidth() * 0.03, y = love.graphics.getHeight() / 3 + textcfg.font:getHeight() + 5 } )
        
    local clientName = ui.textBox( lume.merge( textcfg, { name = "clientName", text = "client",
        y = love.graphics.getHeight() / 3 - textcfg.font:getHeight() * 1.2 - 10, x = love.graphics.getWidth() * 0.03 + love.graphics.getWidth() / 2 } ) )
    local connectText = ui.textBox( lume.merge( textcfg, { name = "connectText", text = "localhost:6789",
        y = love.graphics.getHeight() / 3, x = love.graphics.getWidth() * 0.03 + love.graphics.getWidth() / 2  } ) )

    local connectButton = ui.button( { name = "connectButton", text = "connect", 
        x = love.graphics.getWidth() * 0.03 + love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 3 + textcfg.font:getHeight() + 5 } )        

    if( hostButton.released[1] > 0 ) then
        state = serverState
        serverState.load( hostText.text, hostName.text )
    elseif( connectButton.released[1] > 0 ) then
        state = clientState
        clientState.load( connectText.text, clientName.text )
    end
end


return startState