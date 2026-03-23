local M = {}
local items = require("items")
local repository = {}
local board = require("board")
local function createItem(itemid, calculateprice, buy)
    repository[itemid] = {
        calculateprice = calculateprice,
        buy = buy
    }
end
local function calculateBunUpgradePrice(world)
    return world.avatar.maximumBuns
end
local function buyBunUpgrade(world)
    world.avatar.maximumBuns = world.avatar.maximumBuns + 1
    board.addMessage("+1 Maximum Buns("..world.avatar.maximumBuns..")")
end
local function calculateLotionPrice(world)
    return 10
end
local function buyLotion(world)
    world.avatar.lotions = world.avatar.lotions + 1
    board.addMessage("+1 Lotion("..world.avatar.lotions..")")
end
local function calculateFloggerPrice(world)
    return 25
end
local function buyFlogger(world)
    world.avatar.floggers = world.avatar.floggers + 1
    board.addMessage("+1 Flogger("..world.avatar.floggers..")")
end
function M.load()
    createItem(items.BUN_UPGRADE, calculateBunUpgradePrice, buyBunUpgrade)
    createItem(items.LOTION, calculateLotionPrice, buyLotion)
    createItem(items.FLOGGER, calculateFloggerPrice, buyFlogger)
end
function M.getItemPrice(itemid, world)
    return repository[itemid].calculateprice(world)
end
function M.buy(itemid, world)
    local price = M.getItemPrice(itemid, world)
    world.avatar.jools = world.avatar.jools - price
    board.addMessage("-"..price.." Jools")
    repository[itemid].buy(world)
end
return M