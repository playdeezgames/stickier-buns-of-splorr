local M = {}
function M.create(image,offsetX,offsetY)
    local instance = {}
    instance.image = image
    instance.offsetX = offsetX
    instance.offsetY = offsetY
    instance.draw = draw_sprite
    function instance:draw(x,y)
        love.graphics.draw(self.image, x + self.offsetX, y + self.offsetY)
    end
    return instance
end
return M