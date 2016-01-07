local MysqlPlugin = require('vanilla.v.plugin'):new()

function MysqlPlugin:routerStartup(request, response)
end

function MysqlPlugin:routerShutdown(request, response)
end

function MysqlPlugin:dispatchLoopStartup(request, response)
end

function MysqlPlugin:preDispatch(request, response)
end

function MysqlPlugin:postDispatch(request, response)
    local mysql_replica = require "library.db.mysql.replica"
    local replica = mysql_replica:instance()
    if replica.m then
        replica.m:keepalive()
    end
    for i, client in pairs(replica.slaves) do
        client:keepalive()
    end
end

function MysqlPlugin:dispatchLoopShutdown(request, response)
end

return MysqlPlugin
