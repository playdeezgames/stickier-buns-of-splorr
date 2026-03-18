local M = {}
local constants = require("constants")
local tokens = require("tokens")
local butthole = require("butthole")
local world = {}
local deltas = {
    {x=-2,y=-1},
    {x=-2,y= 1},
    {x= 2,y=-1},
    {x= 2,y= 1},
    {x=-1,y=-2},
    {x=-1,y= 2},
    {x= 1,y=-2},
    {x= 1,y= 2}
}
local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end
local function placeToken(x,y,token)
    world.board[x][y].token = token
end
local function spawnToken(token)
    local x
    local y
    repeat
        x = love.math.random(0, constants.BOARD_WIDTH - 1)
        y = love.math.random(0, constants.BOARD_HEIGHT - 1)
    until world.board[x][y].token == nil
    placeToken(x,y,token)
end
local function unhilite()
    for x = 0, constants.BOARD_WIDTH - 1 do
        for y = 0, constants.BOARD_HEIGHT - 1 do
            world.board[x][y].hilite = false
        end
    end
end
local function hilite()
    unhilite()
    if  world.avatar.health > 0 then
        for _, delta in ipairs(deltas) do
            local x = world.avatar.x + delta.x
            local y = world.avatar.y + delta.y
            if x >= 0 and y >= 0 and x < constants.BOARD_WIDTH and y < constants.BOARD_HEIGHT then
                world.board[x][y].hilite = true
            end
        end
    end
end
function M.initialize()
    world = {}
    world.messages = {}
    world.board = {}
    for x = 0, constants.BOARD_WIDTH - 1 do
        world.board[x] = {}
        for y = 0, constants.BOARD_HEIGHT - 1 do
            world.board[x][y] = {
                light = (x + y) % 2 == 1
            }
        end
    end
    world.avatar = {
        x = love.math.random(0, constants.BOARD_WIDTH - 1),
        y = love.math.random(0, constants.BOARD_HEIGHT - 1),
        buns = 15,
        maximumBuns = 15,
        health = 3,
        maximumHealth = 3,
        armour = 5,
        jools = 0,
        floggers = 0,
        sprays = 0
    }
    world.board[world.avatar.x][world.avatar.y].token = tokens.KNIGHT
    hilite()
    spawnToken(tokens.BUN)
    spawnToken(tokens.BUTTHOLE)
    for _ = 1, constants.PAWN_COUNT do
        spawnToken(tokens.PAWN)
    end
end
function M.getWorld()
    return world
end
local function addMessage(message)
    table.insert(world.messages, 1, message)
    while #world.messages > 15 do
        table.remove(world.messages)
    end
end
local function uncancel()
    for x = 0, constants.BOARD_WIDTH - 1 do
        for y = 0, constants.BOARD_HEIGHT - 1 do
            if world.board[x][y].token == tokens.CANCEL then
                world.board[x][y].token = nil
            end
        end
    end
end
local function changeBuns(delta)
    world.avatar.buns = clamp(world.avatar.buns + delta, 0, world.avatar.maximumBuns)
end
local function changeHealth(delta)
    world.avatar.health = clamp(world.avatar.health + delta, 0, world.avatar.maximumHealth)
end
local function starve()
    if world.avatar.buns > 0 then
        changeBuns(-1)
    else
        changeHealth(-1)
    end
end
local function checkButthole()
    addMessage("Checking butthole...")
    local result = butthole.check()
    if result == butthole.NOTHING then
    elseif result == butthole.JOOLS then
        local jools = 3 + love.math.random(1,3) + love.math.random(1,3)
        world.avatar.jools = world.avatar.jools + jools
        addMessage("+"..jools.." Jools!")
    elseif result == butthole.TRAP then
    elseif result == butthole.TELEPORT then
    elseif result == butthole.ARMOUR then
        world.avatar.armour = world.avatar.armour + 1
        addMessage("+1 Armour!")
    elseif result == butthole.FLOGGER then
        world.avatar.floggers = world.avatar.floggers + 1
        addMessage("+1 Flogger!")
    elseif result == butthole.POTION then
        world.avatar.potions = world.avatar.potions + 1
        addMessage("+1 Potion!")
    end
end
local function takeDamage(damage)
    while damage > 0 and world.avatar.armour > 0 do
        damage = damage - 1
        world.avatar.armour = world.avatar.armour - 1
    end
    while damage > 0 and world.avatar.health > 0 do
        damage = damage - 1
        world.avatar.health = world.avatar.health - 1
    end
end
local function getPawnCount()
    local result = 0
    for x = 0, constants.BOARD_WIDTH - 1 do
        for y = 0 , constants.BOARD_HEIGHT - 1 do
            if world.board[x][y].token == tokens.PAWN then
                result = result + 1
            end
        end
    end
    return result
end
local function spawnBishop()
    spawnToken(tokens.BISHOP)
end
local function attackPawn()
    takeDamage(1)
    if getPawnCount() == 0 then
        spawnBishop()
    end
end
function M.attemptMove(x,y)
    if x < 0 or y < 0 or x >= constants.BOARD_WIDTH or y >= constants.BOARD_HEIGHT then
        return
    end
    local cell = world.board[x][y]
    if not cell.hilite then
        return
    end
    starve()
    uncancel()
    local cancelX, cancelY = world.avatar.x, world.avatar.y
    world.board[cancelX][cancelY].token = tokens.CANCEL
    local token = world.board[x][y].token
    world.avatar.x = x
    world.avatar.y = y
    world.board[world.avatar.x][world.avatar.y].token = tokens.KNIGHT
    hilite()
    world.board[cancelX][cancelY].hilite = false
    if token == tokens.BUN then
        addMessage("+5 buns")
        spawnToken(tokens.BUN)
        changeBuns(5)
    elseif token == tokens.BUTTHOLE then
        checkButthole()
        spawnToken(tokens.BUTTHOLE)
    elseif token == tokens.PAWN then
        attackPawn()
    end
end
return M