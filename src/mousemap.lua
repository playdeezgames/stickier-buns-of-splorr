local constants = require("constants")
local scroller = require("scroller")

local MOUSEMAP_IMAGE_FILENAME = "assets/images/mousemap.png"
local UPPER_LEFT = "ul"
local UPPER_RIGHT = "ur"
local LOWER_LEFT = "ll"
local LOWER_RIGHT = "lr"
local CENTER = "c"
local MINIMUM_X = 0
local MAXIMUM_X = 7
local MINIMUM_Y = 0
local MAXIMUM_Y = 7

local M = {}
function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end
function M.load()
    M.mouseMap = {}
    local mouseMapImageData = love.image.newImageData(MOUSEMAP_IMAGE_FILENAME)
    local width = mouseMapImageData:getWidth();
    local height = mouseMapImageData:getHeight();
    local ulr,ulg,ulb = mouseMapImageData:getPixel(0,0)
    local urr,urg,urb = mouseMapImageData:getPixel(width-1,0)
    local llr,llg,llb = mouseMapImageData:getPixel(0,height-1)
    local lrr,lrg,lrb = mouseMapImageData:getPixel(width-1,height-1)
    for x = 0, width - 1 do
        M.mouseMap[x]={}
        for y = 0, height - 1 do
            local r, g, b = mouseMapImageData:getPixel(x,y)
            if r == ulr and g == ulg and b == ulb then
                M.mouseMap[x][y]=UPPER_LEFT
            elseif r == urr and g == urg and b == urb then
                M.mouseMap[x][y]=UPPER_RIGHT
            elseif r == llr and g == llg and b == llb then
                M.mouseMap[x][y]=LOWER_LEFT
            elseif r == lrr and g == lrg and b == lrb then
                M.mouseMap[x][y]=LOWER_RIGHT
            else
                M.mouseMap[x][y]=CENTER
            end
        end
    end
end
function M.mapXY(x,y)
    local mapX, mapY
    x, y = scroller.fromScreen(x, y)
    local gridX = math.floor(x / constants.TILE_WIDTH)
    local gridY = math.floor(y / constants.TILE_HEIGHT)
    local remainderX = x % constants.TILE_WIDTH
    local remainderY = y % constants.TILE_HEIGHT
    mapX = gridY + gridX
    mapY = gridY - gridX
    local corner = M.mouseMap[remainderX][remainderY]
    if corner == UPPER_LEFT then
        mapX = mapX - 1
    elseif corner == UPPER_RIGHT then
        mapY = mapY - 1
    elseif corner == LOWER_LEFT then
        mapY = mapY + 1
    elseif corner == LOWER_RIGHT then
        mapX = mapX + 1
    end
    return clamp(mapX,MINIMUM_X,MAXIMUM_X), clamp(mapY,MINIMUM_Y,MAXIMUM_Y)
end
return M