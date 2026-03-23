local M = {}
local button = require("button")
local buttons = require("buttons")
local sprites = require("sprites")
local constants = require("constants")
local board = require("board")
local items = require("items")
local itemmanager = require("itemmanager")
local repository = {}
local tooltips = {}
local enablers = {}
local handlers = {}
local function createButton(buttonid, spriteid, hoverSpriteid, x, y, width, height, tooltip, enabler, handler)
    repository[buttonid] = button.create(spriteid, hoverSpriteid, x, y, width, height)
    tooltips[buttonid] = tooltip
    enablers[buttonid] = enabler
    handlers[buttonid] = handler
end
local function isUseLotionEnabled(world)
    return not world.avatar.shoppe and world.avatar.lotions > 0
end
local function isLeaveEnabled(world)
    return world.avatar.shoppe
end
local function handleUseLotion(world)
    board.useLotion()
end
local function handleLeave(world)
    world.avatar.shoppe = false
end
local function getUpgradeBunsToolTip(world)
    local price = itemmanager.getItemPrice(items.BUN_UPGRADE, world)
    return "Upgrade Buns(-"..price.." Jools)"
end
local function isUpgradeBunsEnabled(world)
    local price = itemmanager.getItemPrice(items.BUN_UPGRADE, world)
    return world.avatar.shoppe and world.avatar.jools >= price
end
local function handleUpgradeBuns(world)
    itemmanager.buy(items.BUN_UPGRADE, world)
end
local function getBuyLotionToolTip(world)
    local price = itemmanager.getItemPrice(items.LOTION, world)
    return "Buy Lotion(-"..price.." Jools)"
end
local function isBuyLotionEnabled(world)
    local price = itemmanager.getItemPrice(items.LOTION, world)
    return world.avatar.shoppe and world.avatar.jools >= price
end
local function handleBuyLotion(world)
    itemmanager.buy(items.LOTION, world)
end
local function getFloggerToolTip(world)
    local price = itemmanager.getItemPrice(items.FLOGGER, world)
    return "Buy Flogger(-"..price.." Jools)"
end
local function isFloggerEnabled(world)
    local price = itemmanager.getItemPrice(items.FLOGGER, world)
    return world.avatar.shoppe and world.avatar.jools >= price
end
local function handleFlogger(world)
    itemmanager.buy(items.FLOGGER, world)
end
local function getArmourToolTip(world)
    local price = itemmanager.getItemPrice(items.ARMOUR, world)
    return "Buy Armour(-"..price.." Jools)"
end
local function isArmourEnabled(world)
    local price = itemmanager.getItemPrice(items.ARMOUR, world)
    return world.avatar.shoppe and world.avatar.jools >= price
end
local function handleArmour(world)
    itemmanager.buy(items.ARMOUR, world)
end
function M.load()
    createButton(
        buttons.USE_LOTION, 
        sprites.LOTION, 
        sprites.LOTION_HOVER, 
        constants.USE_LOTION_X, 
        constants.USE_LOTION_Y, 
        constants.USE_LOTION_WIDTH, 
        constants.USE_LOTION_HEIGHT, 
        "Use Lotion", 
        isUseLotionEnabled, 
        handleUseLotion)
    createButton(
        buttons.LEAVE, 
        sprites.LEAVE, 
        sprites.LEAVE_HOVER, 
        constants.LEAVE_X, 
        constants.LEAVE_Y, 
        constants.LEAVE_WIDTH, 
        constants.LEAVE_HEIGHT, 
        "Leave Shoppe", 
        isLeaveEnabled, 
        handleLeave)
    createButton(
        buttons.UPGRADE_BUNS, 
        sprites.UPGRADE_BUNS, 
        sprites.UPGRADE_BUNS_HOVER, 
        constants.UPGRADE_BUNS_X, 
        constants.UPGRADE_BUNS_Y, 
        constants.UPGRADE_BUNS_WIDTH, 
        constants.UPGRADE_BUNS_HEIGHT, 
        getUpgradeBunsToolTip, 
        isUpgradeBunsEnabled, 
        handleUpgradeBuns)
    createButton(
        buttons.BUY_LOTION, 
        sprites.BUY_LOTION, 
        sprites.BUY_LOTION_HOVER, 
        constants.BUY_LOTION_X, 
        constants.BUY_LOTION_Y, 
        constants.BUY_LOTION_WIDTH, 
        constants.BUY_LOTION_HEIGHT, 
        getBuyLotionToolTip, 
        isBuyLotionEnabled, 
        handleBuyLotion)
    createButton(
        buttons.FLOGGER, 
        sprites.FLOGGER, 
        sprites.FLOGGER_HOVER, 
        constants.FLOGGER_X, 
        constants.FLOGGER_Y, 
        constants.FLOGGER_WIDTH, 
        constants.FLOGGER_HEIGHT, 
        getFloggerToolTip, 
        isFloggerEnabled, 
        handleFlogger)
    createButton(
        buttons.ARMOUR, 
        sprites.ARMOUR, 
        sprites.ARMOUR_HOVER, 
        constants.ARMOUR_X, 
        constants.ARMOUR_Y, 
        constants.ARMOUR_WIDTH, 
        constants.ARMOUR_HEIGHT, 
        getArmourToolTip, 
        isArmourEnabled, 
        handleArmour)
end
function M.getButton(buttonid)
    return repository[buttonid]
end
function M.checkHover(x,y)
    for _,v in pairs(repository) do
        v:checkHover(x,y)
    end
end
function M.getToolTip(world)
    for k, v in pairs(repository) do
        if v:isEnabled() and v:getHover() then
            local tooltip = tooltips[k]
            local tooltiptype = type(tooltip)
            if tooltiptype == "function" then
                return tooltip(world)
            else
                return tooltip
            end
        end
    end
    return nil
end
function M.draw()
    for _, v in pairs(repository) do
        v:draw()
    end
end
function M.update(world)
    for k, v in pairs(repository) do
        v:setEnabled(enablers[k](world))
    end
end
function M.handleClick(world)
    for k, v in pairs(repository) do
        if v:isEnabled() and v:getHover() then
            handlers[k](world)
        end
    end
end
return M