local redis_client = require "framework.db.redis.client"
local function tappend(t, v) t[#t+1] = v end

local Replica = {}
Replica.__index = Replica

local replicas = {}

function Replica:instance(name, config)
    if replicas[name] then
        return replicas[name]
    end
    local instance = setmetatable({
        m = redis_client:new(config.master.host, config.master.port,
            config.master.conn_timeout, config.master.pool_size,
            config.master.keepalive_time, config.master.pwd),
        slaves = {},
    }, Replica)
    
    for i, v in pairs(config.slaves) do
        tappend(instance.slaves, redis_client:new(v.host, v.port,
            v.conn_timeout, v.pool_size, v.keepalive_time, v.pwd))
    end

    replicas[name] = instance
    return instance
end

function Replica:master()
    return self.m
end

function Replica:slave()
    math.randomseed(os.clock())
    return self.slaves[math.random(#self.slaves)]
end

return Replica
