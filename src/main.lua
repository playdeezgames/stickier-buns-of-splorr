if arg[#arg] == "debug" then
    require("lldebugger").start()
end
local board = require("board")
local mousemap = require("mousemap")
local constants = require("constants")
local scroller = require("scroller")
local sprite = require("sprite")
local tokens = require("tokens")

local cursorX = 0
local cursorY = 0
local cursorSprite
local lightSprite
local darkSprite
local lightSpriteHilite
local darkSpriteHilite
local knightSprite
local pawnSprite
local bishopSprite
local cancelSprite
local bunSprite
local buttholeSprite
local font
local messageFont

function love.load(args)
    font = love.graphics.newFont("assets/fonts/antiquity-print.ttf", constants.FONT_SIZE)
    messageFont = love.graphics.newFont("assets/fonts/antiquity-print.ttf", constants.MESSAGE_FONT_SIZE)
    bunSprite = sprite.create(love.graphics.newImage("assets/images/bun.png"),40,-20)
    buttholeSprite = sprite.create(love.graphics.newImage("assets/images/butthole.png"),40,20)
    cancelSprite = sprite.create(love.graphics.newImage("assets/images/cancel.png"),40,20)
    lightSprite = sprite.create(love.graphics.newImage("assets/images/lighttile.png"),0,0)
    darkSprite = sprite.create(love.graphics.newImage("assets/images/darktile.png"),0,0)
    lightSpriteHilite = sprite.create(love.graphics.newImage("assets/images/lighttilehilite.png"),0,0)
    darkSpriteHilite = sprite.create(love.graphics.newImage("assets/images/darktilehilite.png"),0,0)
    cursorSprite = sprite.create(love.graphics.newImage("assets/images/cursor.png"),0,0)
    knightSprite = sprite.create(love.graphics.newImage("assets/images/knight.png"),40,-30)
    pawnSprite = sprite.create(love.graphics.newImage("assets/images/pawn.png"),40,-30)
    bishopSprite = sprite.create(love.graphics.newImage("assets/images/bishop.png"),40,-30)
    mousemap.load()
    board.initialize()
end

local function plotXY(x,y)
    return scroller.toScreen((x - y) * (constants.TILE_WIDTH / 2), (x + y) * (constants.TILE_HEIGHT / 2))
end

local function drawBoard(world)
    love.graphics.setColor(255,255,255)
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
            if x == cursorX and y == cursorY then
                cursorSprite:draw(plotX, plotY)
            end
            local token = cell.token
            if token == tokens.KNIGHT then
                knightSprite:draw(plotX, plotY)
            elseif token == tokens.CANCEL then
                cancelSprite:draw(plotX, plotY)
            elseif token == tokens.BUN then
                bunSprite:draw(plotX, plotY)
            elseif token == tokens.BUTTHOLE then
                buttholeSprite:draw(plotX, plotY)
            elseif token == tokens.PAWN then
                pawnSprite:draw(plotX, plotY)
            elseif token == tokens.BISHOP then
                bishopSprite:draw(plotX, plotY)
            end
        end
    end
end

local function drawStats(world)
    love.graphics.setFont(font)
    local y = 0

    love.graphics.setColor(0.66,0,0.66)
    love.graphics.print("Buns: "..world.avatar.buns.."/"..world.avatar.maximumBuns, 0, y)
    y = y + constants.LINE_HEIGHT

    love.graphics.setColor(1,0.33,0.33)
    love.graphics.print("Health: "..world.avatar.health.."/"..world.avatar.maximumHealth, 0, y)
    y = y + constants.LINE_HEIGHT

    love.graphics.setColor(0.33,1,0)
    love.graphics.print("Jools: "..world.avatar.jools, 0, y)
    y = y + constants.LINE_HEIGHT

    love.graphics.setColor(1,1,0.33)
    love.graphics.print("Armour: "..world.avatar.armour, 0, y)
    y = y + constants.LINE_HEIGHT

    love.graphics.setColor(0.33,0.33,0.33)
    love.graphics.print("Floggers: "..world.avatar.floggers, 0, y)
    y = y + constants.LINE_HEIGHT

    love.graphics.setColor(0.66,0,0)
    love.graphics.print("Potions: "..world.avatar.potions, 0, y)
    y = y + constants.LINE_HEIGHT
end

local function drawMessages(world)
    local y = love.graphics.getHeight() - constants.MESSAGE_LINE_HEIGHT
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(messageFont)
    for _, v in ipairs(world.messages) do
        love.graphics.print(v,0,y)
        y = y - constants.MESSAGE_LINE_HEIGHT
    end
end

function love.draw()
    local world = board.getWorld()
    drawBoard(world)
    drawStats(world)
    drawMessages(world)
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
--https://game-icons.net/1x1/sbed/cancel.html
--https://game-icons.net/1x1/caro-asercion/dumpling-bao.html
--https://ninjikin.itch.io/font-antiquity-script

--https://game-icons.net/1x1/skoll/spiked-bat.html
--https://game-icons.net/1x1/delapouite/wood-club.html
--https://game-icons.net/1x1/delapouite/flanged-mace.html

--7z a -tzip -r ..\stickier.love *