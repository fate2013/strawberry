local mysql = require "resty.mysql"

local Client = {
    __index = Client
    instance = {}
}

local function Client:new()
    if self.instance then
        return self.instance
    end
    self.instance = setmetatable({}, Client)
    return self.instance
end

local function Client:connect(host, port, user, password, db, timeout)
    port = port or 3306
    timeout = timeout or 0

    local conn = mysql:new()
    conn:set_timeout(timeout)
    local ok, err, errno, sqlstate = db:connect({
        host = host,
        port = port,
        user = user,
        password = password,
        database = db
    })

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end

    local ok, err = db:set_keepalive()
    if not ok then
        ngx.say("failed to set keepalive: ", err)
        return
    end

    self.conn = conn

    return self
end

local function Client:query(sql)
    local res, err, errno, sqlstate = db:query(sql)

    if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    end

    return res
end

return Client
