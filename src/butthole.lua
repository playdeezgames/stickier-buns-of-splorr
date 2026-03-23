local M = {}
M.NOTHING = "nothing"
M.JOOLS = "jools"
M.TRAP = "trap"
M.TELEPORT = "teleport"
M.ARMOUR = "armour"
M.FLOGGER = "flogger"
M.LOTION = "lotion"
local generator = {}
generator[M.NOTHING] = 10
generator[M.JOOLS] = 40
generator[M.TRAP] = 2000 --TODO: restore to 20
generator[M.TELEPORT] = 10
generator[M.ARMOUR] = 40
generator[M.FLOGGER] = 5
generator[M.LOTION] = 10
function M.check()
    local total = 0
    for _, v in pairs(generator) do
        total = total + v
    end
    local generated = love.math.random(0, total - 1)
    for k, v in pairs(generator) do
        if generated < v then
            return k
        else
            generated = generated - v
        end
    end
end
return M