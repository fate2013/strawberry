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
    --[[
    local mysql_replica = require "library.db.mysql.replica"
    local replica = mysql_replica:instance()
    if replica.m then
        replica.m:keepalive()
    end
    for i, client in pairs(replica.slaves) do
        client:keepalive()
    end
    ]]--

    local redis_client = require "library.db.redis.client"
    if redis_client.obj and redis_client.obj.conn then
        redis_client.obj:keepalive()
    end
end

function RedisPlugin:dispatchLoopShutdown(request, response)
end

return RedisPlugin
