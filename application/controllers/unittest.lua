local cjson = require "cjson"

local UnittestController = {}

function UnittestController:mysqlclient()
    local mysql_client = require "library.db.mysql.client"
    local client = mysql_client:new()
    if not client:connect({
        host = "127.0.0.1",
        user="root",
        password = "",
        database = "fruit",
        timeout = 2000,
    }) then
        return
    end
    res = client:query("select * from user")
    return cjson.encode(res)
end

function UnittestController:mysqlreplica()
    local mysql_replica = require "library.db.mysql.replica"
    local replica = mysql_replica:instance()
    local res = replica:slave():query("select * from user")
    return cjson.encode(res)
end

function UnittestController:redisclient()
    local redis_client = require "library.db.redis.client"
    local client = redis_client:new()
    if not client:connect({
        host = "127.0.0.1",
        timeout = 2000,
    }) then
        return
    end
    res = client:query("get", "dog")
    return cjson.encode(res)
end

function UnittestController:rediscluster()
end

return UnittestController
