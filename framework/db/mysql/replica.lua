local Connection = require "framework.db.mysql.connection"

local Replica = {}
Replica.__index = Replica

local replicas = {}

function Replica:instance(name, config)
    if replicas[name] then
        return replicas[name]
    end
    local instance = setmetatable({
        m = Connection:new(config.master.host, config.master.port, config.master.user,
            config.master.password, config.master.database, config.master.conn_timeout,
            config.master.pool_size, config.master.keepalive_time),
        slaves = {},
    }, Replica)

    for i, v in pairs(config.slaves) do
        tappend(instance.slaves, Connection:new(v.host, v.port, v.user, v.password,
            v.database, v.conn_timeout, v.pool_size, v.keepalive_time))
    end

    replicas[name] = instance
    return instance
end

function Replica:master()
    return self.m
end

function Replica:slave()
    math.randomseed(os.time())
    return self.slaves[math.random(#self.slaves)]
end

return Replica
