local mysql_client = require "library.db.mysql.client"

local Replica = {
    obj = nil,
}
Replica.__index = Replica

function Replica:instance() 
    if self.obj then
        return self.obj
    end
    self.obj = setmetatable({
        config = require "config.mysql",
        m = nil,
        slaves = {},
    }, Replica)
    return self.obj
end

function Replica:master()
    if self.m then
        return self.m
    end
    self.m = mysql_client:new()
    if not self.m:connect(self.config.m) then
        return
    end
    return self.m
end

function Replica:slave()
    math.randomseed(os.time())
    local index = math.random(#self.config.slaves)
    if self.slaves[index] then
        return self.slaves[index]
    end
    self.slaves[index] = mysql_client:new()
    if not self.slaves[index]:connect(self.config.slaves[index]) then
        return
    end
    return self.slaves[index]
end

return Replica
