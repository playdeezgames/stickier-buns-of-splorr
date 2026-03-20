local M = {}
local cursorX = 0
local cursorY = 0
local toolTip = ""
local hoverLotion = false
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
return M