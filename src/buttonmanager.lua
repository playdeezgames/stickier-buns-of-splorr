local M = {}
local button = require("button")
local buttons = require("buttons")
local sprites = require("sprites")
local constants = require("constants")
local repository = {}
local function createButton(buttonid, spriteid, hoverSpriteid, x, y, width, height)
    repository[buttonid] = button.create(spriteid, hoverSpriteid, x, y, width, height)
end
function M.load()
    createButton(buttons.USE_LOTION, sprites.LOTION, sprites.LOTION_HOVER, constants.USE_LOTION_X, constants.USE_LOTION_Y, constants.USE_LOTION_WIDTH, constants.USE_LOTION_HEIGHT)
end
function M.getButton(buttonid)
    return repository[buttonid]
end
return M