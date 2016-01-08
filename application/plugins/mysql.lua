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
    for i, client in pairs(replica.clients) do
        client:keepalive()
    end
    replica.clients = {}
end

function MysqlPlugin:dispatchLoopShutdown(request, response)
end

return MysqlPlugin
