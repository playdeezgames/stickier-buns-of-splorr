local M = {}
local sprites = require("sprites")
local sprite = require("sprite")
local repository = {}
local function createSprite(spriteId, filename, x, y)
    repository[spriteId] = sprite.create(love.graphics.newImage(filename),x,y)
end
function M.load()
    createSprite(sprites.BISHOP, "assets/images/bishop.png", 40, -30)
    createSprite(sprites.BUN, "assets/images/bun.png", 40, -20)
    createSprite(sprites.BUTTHOLE, "assets/images/butthole.png", 40, 20)
    createSprite(sprites.CANCEL, "assets/images/cancel.png", 40, 20)
    createSprite(sprites.CURSOR, "assets/images/cursor.png", 0, 0)
    createSprite(sprites.DARK, "assets/images/darktile.png", 0, 0)
    createSprite(sprites.DARK_HILITE, "assets/images/darktilehilite.png", 0, 0)
    createSprite(sprites.LIGHT, "assets/images/lighttile.png", 0, 0)
    createSprite(sprites.LIGHT_HILITE, "assets/images/lighttilehilite.png", 0, 0)
    createSprite(sprites.LOTION, "assets/images/lotion.png", 0, 0)
    createSprite(sprites.LOTION_HOVER, "assets/images/lotionhover.png", 0, 0)
    createSprite(sprites.KNIGHT, "assets/images/knight.png", 40, -30)
    createSprite(sprites.PAWN, "assets/images/pawn.png", 40, -30)
    createSprite(sprites.BLUR, "assets/images/blur.png", 0, 0)
    createSprite(sprites.SHOPPE, "assets/images/shoppe.png", 40, -30)
    createSprite(sprites.LEAVE, "assets/images/leave.png", 0, 0)
    createSprite(sprites.LEAVE_HOVER, "assets/images/leavehover.png", 0, 0)
    createSprite(sprites.UPGRADE_BUNS, "assets/images/upgradebuns.png", 0, 0)
    createSprite(sprites.UPGRADE_BUNS_HOVER, "assets/images/upgradebunshover.png", 0, 0)
    createSprite(sprites.BUY_LOTION, "assets/images/buylotion.png", 0, 0)
    createSprite(sprites.BUY_LOTION_HOVER, "assets/images/buylotionhover.png", 0, 0)
end
function M.getSprite(spriteId)
    return repository[spriteId]
end
return M