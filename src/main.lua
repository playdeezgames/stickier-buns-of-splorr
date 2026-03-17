if arg[#arg] == "debug" then
    require("lldebugger").start()
end
local board = require("board")
local mousemap = require("mousemap")
local constants = require("constants")
local scroller = require("scroller")
local sprite = require("sprite")

local cursorX = 0
local cursorY = 0
local cursorSprite
local lightSprite
local darkSprite
local lightSpriteHilite
local darkSpriteHilite
local knightSprite
local cancelSprite

function love.load(args)
    cancelSprite = sprite.create(love.graphics.newImage("assets/images/cancel.png"),40,20)
    lightSprite = sprite.create(love.graphics.newImage("assets/images/lighttile.png"),0,0)
    darkSprite = sprite.create(love.graphics.newImage("assets/images/darktile.png"),0,0)
    lightSpriteHilite = sprite.create(love.graphics.newImage("assets/images/lighttilehilite.png"),0,0)
    darkSpriteHilite = sprite.create(love.graphics.newImage("assets/images/darktilehilite.png"),0,0)
    cursorSprite = sprite.create(love.graphics.newImage("assets/images/cursor.png"),0,0)
    knightSprite = sprite.create(love.graphics.newImage("assets/images/knight.png"),40,-30)
    mousemap.load()
    board.initialize()
end

local function plotXY(x,y)
    return scroller.toScreen((x - y) * (constants.TILE_WIDTH / 2), (x + y) * (constants.TILE_HEIGHT / 2))
end

function love.draw()
    local world = board.getWorld()
    for x = 0, constants.BOARD_WIDTH - 1 do
        for y = 0, constants.BOARD_HEIGHT - 1 do
            local cell = world.board[x][y]
            local which
            if cell.light then
                if cell.hilite then
                    which = lightSpriteHilite
                else
                    which = lightSprite
                end
            else
                if cell.hilite then
                    which = darkSpriteHilite
                else
                    which = darkSprite
                end
            end
            local plotX, plotY = plotXY(x,y)
            which:draw(plotX,plotY)
            if cell.cancel then
                cancelSprite:draw(plotX, plotY)
            end
            if x == cursorX and y == cursorY then
                cursorSprite:draw(plotX, plotY)
            end
            if x == world.avatar.x and y == world.avatar.y then
                knightSprite:draw(plotX, plotY)
            end
        end
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    cursorX, cursorY = mousemap.mapXY(x,y)
    --TODO: update tooltip
end

function love.mousepressed(x, y, button, istouch, presses)
    cursorX, cursorY = mousemap.mapXY(x,y)
    board.attemptMove(cursorX, cursorY)
end
--80x80
--https://game-icons.net/1x1/skoll/chess-knight.html
--https://game-icons.net/1x1/skoll/chess-bishop.html
--https://game-icons.net/1x1/skoll/chess-pawn.html
--https://game-icons.net/1x1/sbed/flake.html
--https://game-icons.net/1x1/skoll/spiked-bat.html
--https://game-icons.net/1x1/delapouite/wood-club.html
--https://game-icons.net/1x1/delapouite/flanged-mace.html