local RedisPlugin = require('vanilla.v.plugin'):new()

function RedisPlugin:routerStartup(request, response)
end

function RedisPlugin:routerShutdown(request, response)
end

function RedisPlugin:dispatchLoopStartup(request, response)
end

function RedisPlugin:preDispatch(request, response)
end

function RedisPlugin:postDispatch(request, response)
    local redis_cluster = require "library.db.redis.cluster"
    local cluster = redis_cluster:instance()
    for k, client in pairs(cluster.clients) do
        client:keepalive()
    end
    cluster.clients = {}
end

function RedisPlugin:dispatchLoopShutdown(request, response)
end

return RedisPlugin
