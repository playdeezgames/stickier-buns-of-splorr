local M = {}
local tokens = require("tokens")
local sprites = require("sprites")
local repository = {}
local function createToken(tokenid, tooltip, spriteid)
    repository[tokenid] = {
        tooltip = tooltip,
        spriteid = spriteid
    }
end
function M.load()
    createToken(tokens.BISHOP,"Bishop (enemy, for flogging)",sprites.BISHOP)
    createToken(tokens.BUN,"Stickier Buns", sprites.BUN)
    createToken(tokens.BUTTHOLE,"Butthole (for checking)", sprites.BUTTHOLE)
    createToken(tokens.CANCEL,"YOU! SHALL NOT! PASS!", sprites.CANCEL)
    createToken(tokens.KNIGHT,"Knight (you)", sprites.KNIGHT)
    createToken(tokens.PAWN,"Pawn (enemy)", sprites.PAWN)
    createToken(tokens.SHOPPE, "Shoppe (buy stuff!)", sprites.SHOPPE)
end
function M.getToolTip(tokenid)
    local detail = repository[tokenid]
    if detail == nil then
        return ""
    end
    detail = detail.tooltip
    if detail == nil then
        return ""
    end
    return detail
end
function M.getSpriteId(tokenid)
    local detail = repository[tokenid]
    if detail == nil then
        return nil
    end
    detail = detail.spriteid
    if detail == nil then
        return nil
    end
    return detail
end
return M
