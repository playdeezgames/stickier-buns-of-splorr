local M = {}
local mousemap = require("mousemap")
local cursorX = 0
local cursorY = 0
local toolTip = ""
local hoverLotion = false
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
function M.setHoverLotion(state)
    hoverLotion = state
end
function M.getHoverLotion()
    return hoverLotion
end
function M.mapXY(x,y)
    M.setCursorXY(mousemap.mapXY(x,y))
end
return M