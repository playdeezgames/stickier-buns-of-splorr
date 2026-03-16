local constants = require("constants")
local M={}
function M.toScreen(x,y)
    return math.floor(constants.SCREEN_WIDTH / 2) - math.floor(constants.TILE_WIDTH / 2) + x, y
end
function M.fromScreen(x,y)
    return math.floor(constants.TILE_WIDTH / 2) - math.floor(constants.SCREEN_WIDTH / 2) + x, y
end
return M