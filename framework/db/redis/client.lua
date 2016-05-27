--Deprecated
local redis = require "resty.redis"
local Alarm = require "framework.log.alarm"

local ERR_CODE_REDIS_CONN = 1000000000
local ERR_CODE_REDIS_QUERY = 1000000001

local Client = {}
Client.__index = Client
Client.__tostring = function(self)
    return self.host .. ":" .. self.port .. ":" .. self.conn_timeout
end

function Client:new(host, port, conn_timeout, pool_size, keepalive_time, pwd)
    if not host then host = "127.0.0.1" end
    if not port then port = 6379 end
    if not conn_timeout then conn_timeout = 0 end
    if not pool_size then pool_size = 100 end
    if not keepalive_time then keepalive_time = 10000 end -- 10s

    return setmetatable({
        host = host,
        port = port,
        conn_timeout = conn_timeout,
        pool_size = pool_size,
        keepalive_time = keepalive_time,
        pwd = pwd,
    }, Client)
end

local function connect(host, port, conn_timeout)
    local conn = redis:new()

    conn:set_timeout(conn_timeout)

    local ok, err = conn:connect(host, port)
    if not ok then
        Alarm:new():write("redis", ERR_CODE_REDIS_CONN, ngx.ERR, "connect error, host:" .. host .. ", port:" .. port .. ", timeout:" .. conn_timeout .. ",error:" .. err)
        ngx.log(ngx.ERR, "failed to connect: ", err)
        return
    end

    return conn
end

local function keepalive(conn, pool_size, keepalive_time)
    local ok, err = conn:set_keepalive(keepalive_time, pool_size)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive: ", err)
    end
end

function Client:query(cmd, ...)
    local conn = connect(self.host, self.port, self.conn_timeout)
    if not conn then
        return
    end
    if self.pwd then
        conn:auth(self.pwd)
    end
    local res, err = conn[cmd](conn, ...)
    if err then
        Alarm:new():write("redis", ERR_CODE_REDIS_QUERY, ngx.ERR, "query error, host:" .. self.host .. ", port:" .. self.port .. ", timeout:" .. self.conn_timeout .. ",error:" .. err)
    end
    if not res or res == ngx.null then
        return
    end
    keepalive(conn, self.pool_size, self.keepalive_time)

    return res
end

return Client
