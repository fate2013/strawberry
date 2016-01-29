local redis_client = require "framework.db.redis.client"
local flexihash = require "framework.libs.flexihash"

local DEFAULT_CONNECT_TIMEOUT = 2000

local Cluster = {}
Cluster.__index = Cluster

local clusters = {}

function Cluster:instance(name, config)
    if clusters[name] then
        return clusters[name]
    end
    local instance = setmetatable({
        clients = {},
        flexihash = flexihash:instance(),
    }, Cluster)
    for i, v in pairs(config) do
        local client = redis_client:new(v.host, v.port, v.conn_timeout, v.pool_size, v.keepalive_time, v.pwd)
        instance.clients[tostring(client)] = client
    end
    for i, client in pairs(instance.clients) do
        instance.flexihash:add_target(tostring(client))
    end

    clusters[name] = instance

    return instance
end

function Cluster:query(cmd, ...)
    local key = select(1, ...)
    local target = self.flexihash:lookup(key)
    local client = self.clients[target]
    res = client:query(cmd, ...)
    return res
end

return Cluster
