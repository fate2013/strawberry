-- perf
local setmetatable = setmetatable

local app_userdata = {}

local Registry = {}

function Registry:del(key)
    app_userdata[self.namespace][key] = nil
end

function Registry:get(key)
    if app_userdata[self.namespace][key] ~= nil then
        return app_userdata[self.namespace][key]
    else
        return false
    end
end

function Registry:has(key)
    if app_userdata[self.namespace][key] ~= nil then
        return true 
    else
        return false
    end
end

function Registry:set(key, value)
    app_userdata[self.namespace][key] = value
    return true
end

function Registry:dump(namespace)
    local rs = {}
    if namespace ~= nil then
        rs = app_userdata[namespace]
    else
        rs = app_userdata
    end
    return rs
end

function Registry:new(namespace)
    if namespace == nil then namespace = 'default' end
    if app_userdata[namespace] == nil then app_userdata[namespace] = {} end
    local instance = {
        namespace = namespace,
        del = self.del,
        get = self.get,
        has = self.has,
        dump = self.dump,
        set = self.set
    }
    setmetatable(instance, Registry)
    return instance
end

function Registry:__newindex(index, value)
    if index ~=nil and value ~= nil then
        app_userdata[self.namespace][index]=value
    end
end

function Registry:__index(index)
    local out = rawget(app_userdata[self.namespace], index)
    if out then return out else return false end
end

return Registry
