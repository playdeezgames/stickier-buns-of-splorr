if arg[#arg] == "debug" then
    require("lldebugger").start()
end
local fonts = require "fonts"
local board = require("board")
local constants = require("constants")
local tokens = require("tokens")
local statemachine = require("statemachine")
local spritemanager = require("spritemanager")
local sprites = require("sprites")
local uimanager = require("uimanager")
local fontmanager = require("fontmanager")
local tokenmanager = require("tokenmanager")
local buttonmanager = require("buttonmanager")
local itemmanager = require("itemmanager")

local machine
function love.load(args)
    spritemanager.load()
    fontmanager.load()
    buttonmanager.load()
    uimanager.load()
    tokenmanager.load()
    itemmanager.load()
    machine = statemachine.create()
    machine:load()
    board.initialize()
end

local function drawBoard(world)
    love.graphics.setColor(255,255,255)
    for x = 0, constants.BOARD_WIDTH - 1 do
        for y = 0, constants.BOARD_HEIGHT - 1 do
            local cell = world.board[x][y]
            local which
            if cell.light then
                if cell.hilite then
                    which = spritemanager.getSprite(sprites.LIGHT_HILITE)
                else
                    which = spritemanager.getSprite(sprites.LIGHT)
                end
            else
                if cell.hilite then
                    which = spritemanager.getSprite(sprites.DARK_HILITE)
                else
                    which = spritemanager.getSprite(sprites.DARK)
                end
            end
            local plotX, plotY = uimanager.plotXY(x,y)
            which:draw(plotX,plotY)
            local cursorX, cursorY = uimanager.getCursorXY()
            if not world.avatar.shoppe and x == cursorX and y == cursorY then
                spritemanager.getSprite(sprites.CURSOR):draw(plotX, plotY)
            end
            local token = cell.token
            if token ~= nil then
                local spriteid = tokenmanager.getSpriteId(token)
                if spriteid ~= nil then
                    spritemanager.getSprite(spriteid):draw(plotX, plotY)
                end
            end
        end
    end
end

local function drawStats(world)
    love.graphics.setFont(fontmanager.getFont(fonts.STATISTICS))
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

    love.graphics.setColor(0.66,0.66,0.66)
    love.graphics.print("Lotions: "..world.avatar.lotions, 0, y)
    y = y + constants.LINE_HEIGHT
end

local function drawMessages(world)
    local y = love.graphics.getHeight() - constants.MESSAGE_LINE_HEIGHT
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(fontmanager.getFont(fonts.MESSAGE))
    for _, v in ipairs(world.messages) do
        love.graphics.print(v,0,y)
        y = y - constants.MESSAGE_LINE_HEIGHT
    end
end

local function drawToolTip(world)
    --TODO: if we are hovering over a button, show THAT instead of token tooltip
    local y = 0
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(fontmanager.getFont(fonts.MESSAGE))
    local x = love.graphics.getWidth() - fontmanager.getFont(fonts.MESSAGE):getWidth(uimanager.getToolTip())
    love.graphics.print(uimanager.getToolTip(), x, y)
end

local function drawYerDead(world)
    if world.avatar.health <=0 then
        local text = "Yer Dead!"
        local y = (love.graphics.getHeight() - fontmanager.getFont(fonts.STATISTICS):getHeight())/2
        local x = (love.graphics.getWidth() - fontmanager.getFont(fonts.STATISTICS):getWidth(text)) / 2
        love.graphics.setColor(1,0,0)
        love.graphics.setFont(fontmanager.getFont(fonts.STATISTICS))
        love.graphics.print(text,x,y)
    end
end

local function drawButtons()
    buttonmanager:draw()
end

function love.update(dt)
    buttonmanager.update(board.getWorld())
end

local function drawBlur(world)
    if world.avatar.shoppe then
        spritemanager.getSprite(sprites.BLUR):draw(0,0)
    end
end

function love.draw()
    machine:draw()

    local world = board.getWorld()
    drawBoard(world)
    drawBlur(world)
    drawStats(world)
    drawMessages(world)
    drawToolTip(world)
    drawButtons()
    drawYerDead(world)
end

local function updateToolTip(world)
    local tooltip = buttonmanager.getToolTip(world)
    if tooltip ~= nil then
        uimanager.setToolTip(tooltip)
        return
    end
    if world.avatar.shoppe then
        uimanager.setToolTip("")
        return
    end
    local cursorX, cursorY = uimanager.getCursorXY()
    uimanager.setToolTip(tokenmanager.getToolTip(world.board[cursorX][cursorY].token))
end

function love.mousemoved(x, y, dx, dy, istouch)
    machine:mousemoved(x,y,dx,dy,istouch)

    local world = board.getWorld()
    buttonmanager.checkHover(x,y)
    uimanager.mapXY(x,y)
    updateToolTip(world)
end

function love.mousepressed(x, y, button, istouch, presses)
    machine:mousepressed(x,y,button,istouch,presses)

    uimanager.mapXY(x,y)
    buttonmanager.checkHover(x,y)
    if not buttonmanager.handleClick(board.getWorld()) then
        board.attemptMove(uimanager.getCursorXY())
    end
end
--https://game-icons.net/1x1/skoll/chess-knight.html
--https://game-icons.net/1x1/skoll/chess-bishop.html
--https://game-icons.net/1x1/skoll/chess-pawn.html
--https://game-icons.net/1x1/sbed/flake.html
--https://game-icons.net/1x1/sbed/cancel.html
--https://game-icons.net/1x1/caro-asercion/dumpling-bao.html
--https://ninjikin.itch.io/font-antiquity-script
--https://game-icons.net/1x1/delapouite/liquid-soap.html

--https://game-icons.net/1x1/skoll/spiked-bat.html
--https://game-icons.net/1x1/delapouite/wood-club.html
--https://game-icons.net/1x1/delapouite/flanged-mace.html

--7z a -tzip -r ..\stickier.love *

--TODO:
--restart game
--shoppe
--xp and xp levels
--trap spray
--traps
--teleports
--streak?

--buttons:
--use lotion
--leave shoppe
--buy lotion
--buy flogger
--buy spray
--buy armor
--buy supplies