local mongol = require "resty.mongol"

local Connection = {}
Connection.__index = Connection
Connection.__tostring = function(self)
    return self.host .. ":" .. self.port .. ":" .. self.conn_timeout
end

function Connection:new(host, port, dbname, user, password, conn_timeout, pool_size, keepalive_time)
    if not host then host = "127.0.0.1" end
    if not port then port = 27017 end
    if not conn_timeout then conn_timeout = 0 end
    if not pool_size then pool_size = 100 end
    if not keepalive_time then keepalive_time = 10000 end -- 10s

    return setmetatable({
        host = host,
        port = port,
        dbname = dbname,
        conn_timeout = conn_timeout,
        pool_size = pool_size,
        keepalive_time = keepalive_time,
        user = user,
        password = password,
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

local function get_collection(self, colname)
    local conn = connect(self.host, self.port, self.conn_timeout)
    if not conn then
        return
    end

    local db = conn:new_db_handle(self.dbname)
    if not db then
        return conn, nil
    end

    if self.user and self.password then
        local ok, err = db:auth_scram_sha1(self.user, self.password)
        if not ok then
            ngx.log(ngx.ERR, "failed to auth mongo: ", err)
            return
        end
    end

    local col = db:get_col(colname)
    if not col then
        return conn, nil
    end

    return conn, col
end

function Connection:query(colname, query, return_fields, number_to_skip, number_to_return, options)
    local conn, col = get_collection(self, colname)
    if not conn then
        return
    end

    if not col then
        keepalive(conn, self.pool_size, self.keepalive_time)
        return
    end
    
    local id, results, t = col:query(query, return_fields, number_to_skip, number_to_return, options)
    if id ~= "\0\0\0\0\0\0\0\0" or not results[1] then
        keepalive(conn, self.pool_size, self.keepalive_time)
        return nil
    end

    keepalive(conn, self.pool_size, self.keepalive_time)
    return results
end

function Connection:query_one(colname, query, return_fields, number_to_skip, options)
    local results = self:query(colname, query, return_fields, number_to_skip, 1, options)
    if results and #results > 0 then
        return results[1]
    else
        return nil
    end
end

function Connection:insert(colname, docs, continue_on_error, safe)
    if not continue_on_error then continue_on_error = 0 end
    if not safe then safe = true end

    local conn, col = get_collection(self, colname)
    if not conn then
        return
    end

    if not col then
        keepalive(conn, self.pool_size, self.keepalive_time)
        return
    end

    local n, err = col:insert(docs, continue_on_error, safe)
    if not n then
        ngx.log(ngx.ERR, "failed to insert into mongo: ", err)
        keepalive(conn, self.pool_size, self.keepalive_time)
        return
    end

    keepalive(conn, self.pool_size, self.keepalive_time)
    return n
end

function Connection:delete(colname, selector, single_remove, safe)
    if not single_remove then single_remove = 0 end
    if not safe then safe = true end

    local conn, col = get_collection(self, colname)
    if not conn then
        return
    end

    if not col then
        keepalive(conn, self.pool_size, self.keepalive_time)
        return
    end

    local n, err = col:delete(selector, single_remove, safe)
    if not n then
        ngx.log(ngx.ERR, "failed to delete from mongo: ", err)
        keepalive(conn, self.pool_size, self.keepalive_time)
        return
    end

    keepalive(conn, self.pool_size, self.keepalive_time)
    return n
end

return Connection
