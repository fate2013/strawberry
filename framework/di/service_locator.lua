local ServiceLocator = {}

ServiceLocator.__index = ServiceLocator

function ServiceLocator:new()
    return setmetatable({
        components = {},
    }, ServiceLocator)
end

function ServiceLocator:register()
end

function ServiceLocator:get(id)
    
end

return ServiceLocator
