local M = {}
function M.create(image,offsetX,offsetY)
    local instance = {}
    instance.image = image
    instance.offsetX = offsetX
    instance.offsetY = offsetY
    function instance:draw(x,y)
        love.graphics.draw(self.image, x + self.offsetX, y + self.offsetY)
    end
    return instance
end
return M