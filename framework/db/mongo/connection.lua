local mongol = require "resty.mongol"
local conn = mongol:new() -- return a conntion object

local Connection = {}
Connection.__index = Connection
Connection.__tostring = function(self)
    return self.host .. ":" .. self.port .. ":" .. self.conn_timeout
end

function Connection:new(host, port, conn_timeout, pool_size, keepalive_time)
    if not host then host = "127.0.0.1" end
    if not port then port = 27017 end
    if not conn_timeout then conn_timeout = 0 end
    if not pool_size then pool_size = 100 end
    if not keepalive_time then keepalive_time = 10000 end -- 10s

    return setmetatable({
        host = host,
        port = port,
        conn_timeout = conn_timeout,
        pool_size = pool_size,
        keepalive_time = keepalive_time,
    }, Connection)
end

local function connect(host, port, conn_timeout)
    local conn = mongol:new()

    conn:set_timeout(conn_timeout)

    local ok, err = conn:connect(host, port)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect mongo: ", err)
        return
    end

    return conn
end

local function keepalive(conn, pool_size, keepalive_time)
    local ok, err = conn:set_keepalive(keepalive_time, pool_size)
    if not ok then
        ngx.log(ngx.ERR, "failed to set keepalive to mongo: ", err)
    end
end

function Connection:query(dbname, colname, query, returnfields, numberToSkip, numberToReturn, options)
    local conn = connect(self.host, self.port, self.conn_timeout)
    if not conn then
        return
    end

    local db = conn:new_db_handle(dbname)
    if not db then
        keepalive(conn, self.pool_size, self.keepalive_time)
        return
    end

    local col = db:get_col(colname)
    if not col then
        keepalive(conn, self.pool_size, self.keepalive_time)
        return
    end

    local id, results, t = col:query(query, returnfields, numberToSkip, numberToReturn, options)
    if id ~= "\0\0\0\0\0\0\0\0" or not results[1] then
        keepalive(conn, self.pool_size, self.keepalive_time)
        return nil
    end

    keepalive(conn, self.pool_size, self.keepalive_time)
    return results
end

return Connection
