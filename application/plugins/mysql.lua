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
    local client = require "library.db.mysql.client"
    for i, conn in pairs(client.clients) do
        conn:keepalive()
    end
    client.clients = {}
end

function MysqlPlugin:dispatchLoopShutdown(request, response)
end

return MysqlPlugin
