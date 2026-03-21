local M = {}
local fonts = require("fonts")
local constants = require("constants")
local repository = {}
local function createFont(fontid, filename, size)
    repository[fontid] = love.graphics.newFont(filename, size)
end
function M.load()
    createFont(fonts.MESSAGE, "assets/fonts/antiquity-print.ttf", constants.MESSAGE_FONT_SIZE)
    createFont(fonts.STATISTICS, "assets/fonts/antiquity-print.ttf", constants.STATISTICS_FONT_SIZE)
end
function M.getFont(fontid)
    return repository[fontid]
end
return M