local redis_client = require "library.db.redis.client"

local DEFAULT_CONNECT_TIMEOUT = 2000

local Cluster = {}
Cluster.__index = Cluster

function Cluster:instance(cluster)
    if not cluster then cluster = "default" end
    if self.obj then
        return self.obj
    end
    local config = require "config.redis"
    self.obj = setmetatable({
        config = {},
    }, Cluster)
    local cluster_config = config.clusters[cluster]
    if type(cluster_config) ~= "table" then
        return
    end
    for k, v in pairs(config.clusters[cluster]) do
        if not v.port then v.port = 6379 end
        if not v.timeout then v.timeout = DEFAULT_CONNECT_TIMEOUT end
        self.obj.config[v.host .. ":" .. v.port] = v
    end
    local util_flexihash = require "library.utils.flexihash"
    self.obj.hasher = util_flexihash:instance()
    for target, config in pairs(self.obj.config) do
        self.obj.hasher:add_target(target)
    end
    return self.obj
end

function Cluster:query(cmd, ...)
    local key = select(1, ...)
    local target = self.obj.hasher:lookup(key)
    local index = string.find(target, ":")

    local client = redis_client:new()
    if not client:connect({
        host = target:sub(0, index - 1),
        port = target:sub(index + 1),
        timeout = self.config[target].timeout,
    }) then
        return
    end
    res = client:query(cmd, ...)
    return res
end

return Cluster
