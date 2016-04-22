local ServiceLocator = {}

ServiceLocator.__index = ServiceLocator

function ServiceLocator:new()
    return setmetatable({
        instances = {},
        classes = {},
    }, ServiceLocator)
end

function ServiceLocator:instance(id, instance)
    self.instances[id] = instance
end

function ServiceLocator:register(id, definition)
    self.classes[id] = {}
    self.classes[id]['class'] = definition['class']
    definition['class'] = nil
    self.classes[id]['params'] = definition
end

function ServiceLocator:get(id)
    local instance
    if self.instances[id] then
        instance = self.instances[id]
    elseif self.classes[id] then
        local Class = require(self.classes[id]['class'])
        instance = Class:new(self.classes[id]['params'])
    end
    return instance
end

return ServiceLocator
