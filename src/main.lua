if arg[#arg] == "debug" then
    require("lldebugger").start()
end
local board = require("board")
local mousemap = require("mousemap")
local constants = require("constants")
local scroller = require("scroller")
local tokens = require("tokens")
local statemachine = require("statemachine")
local spritemanager = require("spritemanager")
local sprites = require("sprites")
local uimanager = require("uimanager")

--TODO: font manager?
local font
local messageFont

--TODO: ui manager?
local cursorX = 0
local cursorY = 0
local toolTip = ""

local machine
function love.load(args)
    spritemanager.load()
    machine = statemachine.create()
    machine:load()

    font = love.graphics.newFont("assets/fonts/antiquity-print.ttf", constants.FONT_SIZE)
    messageFont = love.graphics.newFont("assets/fonts/antiquity-print.ttf", constants.MESSAGE_FONT_SIZE)
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
            local plotX, plotY = plotXY(x,y)
            which:draw(plotX,plotY)
            if x == cursorX and y == cursorY then
                spritemanager.getSprite(sprites.CURSOR):draw(plotX, plotY)
            end
            local token = cell.token
            if token == tokens.KNIGHT then
                spritemanager.getSprite(sprites.KNIGHT):draw(plotX, plotY)
            elseif token == tokens.CANCEL then
                spritemanager.getSprite(sprites.CANCEL):draw(plotX, plotY)
            elseif token == tokens.BUN then
                spritemanager.getSprite(sprites.BUN):draw(plotX, plotY)
            elseif token == tokens.BUTTHOLE then
                spritemanager.getSprite(sprites.BUTTHOLE):draw(plotX, plotY)
            elseif token == tokens.PAWN then
                spritemanager.getSprite(sprites.PAWN):draw(plotX, plotY)
            elseif token == tokens.BISHOP then
                spritemanager.getSprite(sprites.BISHOP):draw(plotX, plotY)
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

    love.graphics.setColor(0.66,0.66,0.66)
    love.graphics.print("Lotions: "..world.avatar.lotions, 0, y)
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

local function drawToolTip()
    local y = 0
    love.graphics.setColor(1,1,1)
    love.graphics.setFont(messageFont)
    local x = love.graphics.getWidth() - messageFont:getWidth(toolTip)
    love.graphics.print(toolTip, x, y)
end

local function drawPotionButton(world)
    if world.avatar.lotions == 0 then
        return
    end
    local sprite = spritemanager.getSprite(sprites.LOTION)
    if uimanager.getHoverLotion() then
        sprite = spritemanager.getSprite(sprites.LOTION_HOVER)
    end
    sprite:draw(constants.LOTION_X, constants.LOTION_Y)
end

local function drawYerDead(world)
    if world.avatar.health <=0 then
        local text = "Yer Dead!"
        local y = (love.graphics.getHeight() - font:getHeight())/2
        local x = (love.graphics.getWidth() - font:getWidth(text)) / 2
        love.graphics.setColor(1,0,0)
        love.graphics.setFont(font)
        love.graphics.print(text,x,y)
    end
end

function love.draw()
    machine:draw()

    local world = board.getWorld()
    drawBoard(world)
    drawStats(world)
    drawMessages(world)
    drawToolTip()
    drawPotionButton(world)
    drawYerDead(world)
end

local function updateHoverLotion(world,x,y)
    uimanager.setHoverLotion((world.avatar.lotions > 0) and (x >= constants.LOTION_X) and (y >= constants.LOTION_Y))
end

local function updateToolTip(world)
    if uimanager.getHoverLotion() then
        toolTip = "Use Lotion"
        return
    end
    local token = world.board[cursorX][cursorY].token
    if token == tokens.BUN then
        toolTip = "Stickier Buns"
    elseif token == tokens.BISHOP then
        toolTip = "Bishop (enemy, for flogging)"
    elseif token == tokens.BUTTHOLE then
        toolTip = "Butthole (for checking)"
    elseif token == tokens.CANCEL then
        toolTip = "YOU! SHALL NOT! PASS!"
    elseif token == tokens.KNIGHT then
        toolTip = "Knight (you)"
    elseif token == tokens.PAWN then
        toolTip = "Pawn (enemy)"
    else
        toolTip = ""
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    machine:mousemoved(x,y,dx,dy,istouch)

    local world = board.getWorld()
    updateHoverLotion(world,x,y)
    cursorX, cursorY = mousemap.mapXY(x,y)
    updateToolTip(world)
end

function love.mousepressed(x, y, button, istouch, presses)
    machine:mousepressed(x,y,button,istouch,presses)

    local world = board.getWorld()
    updateHoverLotion(world,x,y)
    cursorX, cursorY = mousemap.mapXY(x,y)
    if uimanager.getHoverLotion() then
        board.useLotion()
    else
        board.attemptMove(cursorX, cursorY)
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