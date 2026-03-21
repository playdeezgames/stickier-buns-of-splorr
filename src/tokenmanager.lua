local M = {}
local tokens = require("tokens")
local repository = {}
local function createToken(tokenid, tooltip)
    repository[tokenid] = {
        tooltip=tooltip
    }
end
function M.load()
    createToken(tokens.BISHOP,"Bishop (enemy, for flogging)")
    createToken(tokens.BUN,"Stickier Buns")
    createToken(tokens.BUTTHOLE,"Butthole (for checking)")
    createToken(tokens.CANCEL,"YOU! SHALL NOT! PASS!")
    createToken(tokens.KNIGHT,"Knight (you)")
    createToken(tokens.PAWN,"Pawn (enemy)")
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
return M
