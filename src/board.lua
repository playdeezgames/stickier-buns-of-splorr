local M = {}
local constants = require("constants")
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
local function uncancel()
    for x = 0, constants.BOARD_WIDTH - 1 do
        for y = 0, constants.BOARD_HEIGHT - 1 do
            world.board[x][y].cancel = false
        end
    end
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
    uncancel()
    hilite()
end
function M.getWorld()
    return world
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
    world.board[cancelX][cancelY].cancel = true
    world.avatar.x = x
    world.avatar.y = y
    hilite()
    world.board[cancelX][cancelY].hilite = false
end
return M