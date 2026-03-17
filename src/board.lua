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
    for _, delta in ipairs(deltas) do
        local x = world.avatar.x + delta.x
        local y = world.avatar.y + delta.y
        if x >= 0 and y >= 0 and x < constants.BOARD_WIDTH and y < constants.BOARD_HEIGHT then
            world.board[x][y].hilite = true
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
        y = love.math.random(0, constants.BOARD_HEIGHT - 1)
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
function M.attemptMove(x,y)
    if x < 0 or y < 0 or x >= constants.BOARD_WIDTH or y >= constants.BOARD_HEIGHT then
        return
    end
    local cell = world.board[x][y]
    if not cell.hilite then
        return
    end
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
    elseif token == tokens.BUTTHOLE then
        spawnToken(tokens.BUTTHOLE)
    end
end
return M