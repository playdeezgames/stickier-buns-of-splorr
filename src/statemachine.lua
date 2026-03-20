local M = {}
local states = require("states")
local inplaystate = require("inplaystate")
function M.create()
    local instance = {}
    instance.states = {}
    instance.states[states.IN_PLAY] = inplaystate.create(instance)
    instance.stateid = nil
    function instance:getCurrentState()
        return instance.states[instance.stateid]
    end
    function instance:setCurrentStateId(stateId)
        instance.stateid = stateId
    end
    function instance:load()
        for _,v in pairs(self.states) do
            v:load()
        end
        self:setCurrentStateId(states.IN_PLAY)
    end
    function instance:draw()
        self:getCurrentState():draw()
    end
    function instance:mousemoved(x,y,dx,dy,istouch)
        self:getCurrentState():mousemoved(x,y,dx,dy,istouch)
    end
    function instance:mousepressed(x,y,button,istouch,presses)
        self:getCurrentState():mousepressed(x,y,button,istouch,presses)
    end
    return instance
end
return M