local M = {}
local button = require("button")
local buttons = require("buttons")
local sprites = require("sprites")
local constants = require("constants")
local repository = {}
local tooltips = {}
local enablers = {}
local function createButton(buttonid, spriteid, hoverSpriteid, x, y, width, height, tooltip, enabler)
    repository[buttonid] = button.create(spriteid, hoverSpriteid, x, y, width, height)
    tooltips[buttonid] = tooltip
    enablers[buttonid] = enabler
end
local function isUseLotionEnabled(world)
    return world.avatar.lotions > 0
end
function M.load()
    createButton(buttons.USE_LOTION, sprites.LOTION, sprites.LOTION_HOVER, constants.USE_LOTION_X, constants.USE_LOTION_Y, constants.USE_LOTION_WIDTH, constants.USE_LOTION_HEIGHT, "Use Lotion", isUseLotionEnabled)
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
return M