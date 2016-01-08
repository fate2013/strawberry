local mysql_client = require "library.db.mysql.client"

local Replica = {
    obj = nil
}
Replica.__index = Replica

function Replica:instance() 
    if self.obj then
        return self.obj
    end
    self.obj = setmetatable({
        config = require "config.mysql",
        clients = {},
    }, Replica)
    return self.obj
end

function Replica:master()
    local client = mysql_client:new()
    if not client:connect(self.config.master) then
        return
    end
    table.insert(self.clients, client)
    return client
end

function Replica:slave()
    math.randomseed(os.time())
    local index = math.random(#self.config.slaves)
    local client = mysql_client:new()
    if not client:connect(self.config.slaves[index]) then
        return
    end
    table.insert(self.clients, client)
    return client
end

return Replica
