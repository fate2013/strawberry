local mysql_client = require "library.db.mysql.client"

local Replica = {
    obj = {}
}
Replica.__index = Replica

function Replica:instance(db)
    if not db then db = "default" end
    if self.obj[db] then
        return self.obj[db]
    end
    local config = require "config.mysql"
    local db_config = config[db]
    if type(db_config) ~= "table" then
        return
    end
    self.obj[db] = setmetatable({
        config = db_config,
    }, Replica)
    return self.obj[db]
end

function Replica:master()
    local client = mysql_client:new()
    if not client:connect(self.config.master) then
        return
    end
    return client
end

function Replica:slave()
    math.randomseed(os.time())
    local index = math.random(#self.config.slaves)
    local client = mysql_client:new()
    if not client:connect(self.config.slaves[index]) then
        return
    end
    return client
end

return Replica
