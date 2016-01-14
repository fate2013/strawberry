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
    local redis = require "library.db.redis.client"
    for k, client in pairs(redis.clients) do
        client:keepalive()
    end
    redis.clients = {}
end

function RedisPlugin:dispatchLoopShutdown(request, response)
end

return RedisPlugin
