local M = {}
function M.create(machine)
    local instance = {}
    instance.machine = machine
    function instance:getMachine()
        return self.machine
    end
    function instance:load()
    end
    function instance:draw()
    end
    function instance:mousemoved(x,y,dx,dy,istouch)
    end
    function instance:mousepressed(x,y,button,istouch,presses)
    end
    return instance
end
return M