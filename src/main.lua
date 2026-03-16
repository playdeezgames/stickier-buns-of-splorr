if arg[#arg] == "debug" then
    require("lldebugger").start()
end
local mousemap = require("mousemap")
local constants = require("constants")
local scroller = require("scroller")
local sprite = require("sprite")

local cursorX = 0
local cursorY = 0
local cursorSprite
local lightSprite
local darkSprite

function love.load(args)
    lightSprite = sprite.create(love.graphics.newImage("assets/images/lighttile.png"),0,0)
    darkSprite = sprite.create(love.graphics.newImage("assets/images/darktile.png"),0,0)
    cursorSprite = sprite.create(love.graphics.newImage("assets/images/cursor.png"),0,0)
    mousemap.load()
end

function plotXY(x,y)
    return scroller.toScreen((x - y) * (constants.TILE_WIDTH / 2), (x + y) * (constants.TILE_HEIGHT / 2))
end

function love.draw()
    for x = 0, 7 do
        for y = 0, 7 do
            local which = lightSprite
            if (x+y)%2==1 then
                which = darkSprite
            end
            local plotX, plotY = plotXY(x,y)
            which:draw(plotX,plotY)
            if x == cursorX and y == cursorY then
                cursorSprite:draw(plotX, plotY)
            end
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    cursorX, cursorY = mousemap.mapXY(x,y)
end
--80x80
--https://game-icons.net/1x1/skoll/chess-knight.html
--https://game-icons.net/1x1/skoll/chess-bishop.html
--https://game-icons.net/1x1/skoll/chess-pawn.html
--https://game-icons.net/1x1/sbed/flake.html
--https://game-icons.net/1x1/skoll/spiked-bat.html
--https://game-icons.net/1x1/delapouite/wood-club.html
--https://game-icons.net/1x1/delapouite/flanged-mace.html