local M = {}
local mousemap = require("mousemap")
local scroller = require("scroller")
local constants = require("constants")
local cursorX = 0
local cursorY = 0
local toolTip = ""
function M.load()
    mousemap.load()
end
function M.setCursorXY(x,y)
    cursorX, cursorY = x, y
end
function M.getCursorXY()
    return cursorX, cursorY
end
function M.setToolTip(text)
    toolTip = text
end
function M.getToolTip()
    return toolTip
end
function M.mapXY(x,y)
    M.setCursorXY(mousemap.mapXY(x,y))
end
function M.plotXY(x,y)
    return scroller.toScreen((x - y) * (constants.TILE_WIDTH / 2), (x + y) * (constants.TILE_HEIGHT / 2))
end
return M