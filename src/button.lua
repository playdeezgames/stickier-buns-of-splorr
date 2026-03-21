local M = {}
local spritemanager = require("spritemanager")
function M.create(spriteid, hoverSpriteid, x, y, width, height)
    local instance = {}
    instance.spriteid = spriteid
    instance.hoverSpriteid = hoverSpriteid
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.enabled = false
    instance.hover = false
    function instance:setEnabled(enabled)
        instance.enabled = enabled
    end
    function instance:isEnabled()
        return instance.enabled
    end
    function instance:checkHover(x, y)
        instance.hover = x >= instance.x and y >= instance.y and x < (instance.x + instance.width) and y < (instance.y + instance.height)
    end
    function instance:getHover()
        return instance.hover
    end
    function instance:draw()
        if not instance:isEnabled() then
            return
        end
        local spriteid = instance.spriteid
        if instance:getHover() then
            spriteid = instance.hoverSpriteid
        end
        spritemanager.getSprite(spriteid):draw(instance.x, instance.y)
    end
    return instance
end
return M