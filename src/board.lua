local M = {}
local constants = require("constants")
local tokens = require("tokens")
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
        maximumHealth = 3
    }
    world.board[world.avatar.x][world.avatar.y].token = tokens.KNIGHT
    hilite()
    spawnToken(tokens.BUN)
    spawnToken(tokens.BUTTHOLE)
end
function M.getWorld()
    return world
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
        spawnToken(tokens.BUN)
        changeBuns(5)
    elseif token == tokens.BUTTHOLE then
        spawnToken(tokens.BUTTHOLE)
    end
end
return M