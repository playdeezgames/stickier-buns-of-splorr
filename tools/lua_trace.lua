-- Plays the ORIGINAL Lua game logic (src/) under a scripted policy and prints a checksum of the
-- full game state every few steps. The Odin test test_parity_with_lua_trace replays the same
-- policy on the Odin rules and must produce identical checksums.
--
--   lua5.4 tools/lua_trace.lua > odin/game/testdata/lua_trace.txt     (from the repo root)
--   LUA_TRACE_FULL=1 lua5.4 tools/lua_trace.lua                       (prints full state lines)
--
-- Plain Lua is enough: the rules only touch love.math.random, which is replaced by a small LCG.
-- One deliberate change: butthole.check iterates its weights in a fixed order (the original used
-- pairs, whose order is unspecified), with the same weights and the same single random draw.

package.path = "src/?.lua;" .. package.path

local FULL = os.getenv("LUA_TRACE_FULL") ~= nil
local CHECKPOINT = 5

-- Two independent LCG streams: one for the game (love.math.random), one for the policy.
local function newStream(seed)
    local state = seed
    return function(lo, hi)
        state = (state * 1103515245 + 12345) & 0x7fffffff
        return lo + (state >> 8) % (hi - lo + 1)
    end
end

local gameRandom
love = { math = { random = function(lo, hi) return gameRandom(lo, hi) end } }

package.loaded["butthole"] = (function()
    local M = {}
    M.NOTHING, M.JOOLS, M.TRAP, M.TELEPORT = "nothing", "jools", "trap", "teleport"
    M.ARMOUR, M.FLOGGER, M.LOTION = "armour", "flogger", "lotion"
    local order = {
        { M.NOTHING, 10 }, { M.JOOLS, 40 }, { M.TRAP, 20 }, { M.TELEPORT, 10 },
        { M.ARMOUR, 40 }, { M.FLOGGER, 5 }, { M.LOTION, 10 },
    }
    function M.check()
        local total = 0
        for _, e in ipairs(order) do total = total + e[2] end
        local generated = love.math.random(0, total - 1)
        for _, e in ipairs(order) do
            if generated < e[2] then return e[1] end
            generated = generated - e[2]
        end
    end
    return M
end)()

local constants = require("constants")
local tokens = require("tokens")
local board = require("board")
local items = require("items")
local itemmanager = require("itemmanager")
local buttons = require("buttons")
local buttonmanager = require("buttonmanager")
itemmanager.load()
buttonmanager.load()

local tokenCode = {
    [tokens.KNIGHT] = "K", [tokens.BUN] = "B", [tokens.BUTTHOLE] = "H", [tokens.CANCEL] = "C",
    [tokens.PAWN] = "P", [tokens.BISHOP] = "I", [tokens.SHOPPE] = "S",
}
local buttonOrder = {
    buttons.USE_LOTION, buttons.PLAY, buttons.LEAVE, buttons.UPGRADE_BUNS,
    buttons.BUY_LOTION, buttons.FLOGGER, buttons.ARMOUR, buttons.SPRAY,
}
local itemOrder = { items.BUN_UPGRADE, items.LOTION, items.FLOGGER, items.ARMOUR, items.SPRAY }

local function stateLine(world)
    local a = world.avatar
    local parts = {}
    parts[#parts + 1] = string.format("a:%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",
        a.x, a.y, a.buns, a.maximumBuns, a.health, a.maximumHealth, a.armour, a.jools,
        a.floggers, a.sprays, a.lotions, a.shoppe and 1 or 0, a.xp, a.xpGoal, a.xpLevel)
    local t, h = {}, {}
    for x = 0, constants.BOARD_WIDTH - 1 do
        for y = 0, constants.BOARD_HEIGHT - 1 do
            local cell = world.board[x][y]
            t[#t + 1] = tokenCode[cell.token] or "."
            h[#h + 1] = cell.hilite and "1" or "0"
        end
    end
    parts[#parts + 1] = "T:" .. table.concat(t)
    parts[#parts + 1] = "H:" .. table.concat(h)
    buttonmanager.update(world)
    local e = {}
    for _, id in ipairs(buttonOrder) do
        e[#e + 1] = buttonmanager.getButton(id):isEnabled() and "1" or "0"
    end
    parts[#parts + 1] = "E:" .. table.concat(e)
    parts[#parts + 1] = "M:" .. table.concat(world.messages, ";")
    return table.concat(parts, "|")
end

local function fnv(s)
    local hash = 2166136261
    for i = 1, #s do
        hash = ((hash ~ s:byte(i)) * 16777619) & 0xffffffff
    end
    return hash
end

local function movePriority(token, buns)
    if token == tokens.SHOPPE then return 6
    elseif token == tokens.BISHOP then return 5
    elseif token == tokens.BUN then return (buns < 6) and 4 or 1
    elseif token == tokens.BUTTHOLE then return 3
    elseif token == tokens.PAWN then return 2
    end
    return 0
end

local function run(seed, cheat, steps)
    gameRandom = newStream(seed)
    local policy = newStream(seed + 1000)
    board.initialize()
    print(string.format("run %d %d %d", seed, cheat and 1 or 0, steps))
    local function emit(step)
        local line = stateLine(board.getWorld())
        if FULL then print(step, line) else print(fnv(line)) end
    end
    emit(0)
    for step = 1, steps do
        local world = board.getWorld()
        local a = world.avatar
        if a.health <= 0 then
            board.initialize()
        else
            if cheat then
                a.armour = math.max(a.armour, 4)
                a.buns = math.max(a.buns, 3)
            end
            if a.shoppe then
                for _, item in ipairs(itemOrder) do
                    while a.jools >= itemmanager.getItemPrice(item, world) and policy(0, 1) == 0 do
                        itemmanager.buy(item, world)
                    end
                end
                a.shoppe = false
            end
            if a.lotions > 0 and a.health < a.maximumHealth then
                board.useLotion()
            end
            local moves = {}
            for x = 0, constants.BOARD_WIDTH - 1 do
                for y = 0, constants.BOARD_HEIGHT - 1 do
                    if world.board[x][y].hilite then moves[#moves + 1] = { x, y } end
                end
            end
            local pick = moves[policy(0, #moves - 1) + 1]
            if policy(0, 9) < 8 then
                local best = -1
                for _, m in ipairs(moves) do
                    local p = movePriority(world.board[m[1]][m[2]].token, a.buns)
                    if p > best then best = p; pick = m end
                end
            end
            board.attemptMove(pick[1], pick[2])
        end
        if step % CHECKPOINT == 0 then emit(step) end
    end
end

run(1, true, 2000)
run(2, true, 2000)
run(3, false, 2000)
run(4, false, 2000)
run(5, true, 2000)
run(6, false, 2000)
