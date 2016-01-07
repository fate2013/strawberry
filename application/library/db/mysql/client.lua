local mysql = require "resty.mysql"

local Client = {
    obj = nil
}
Client.__index = Client

function Client:new()
    return setmetatable({
        conn = nil
    }, Client)
end

function Client:instance()
    if self.obj then
        return self.obj
    end
    self.obj = setmetatable({
        conn = nil
    }, Client)
    return self.obj
end

function Client:connect(args)
    if not args.timeout then args.timeout = 0 end
    if not args.port then args.port = 3306 end

    if self.conn then
        return self
    end
    local conn = mysql:new()
    conn:set_timeout(args.timeout)
    local ok, err, errno, sqlstate = conn:connect({
        host = args.host,
        port = args.port,
        user = args.user,
        password = args.password,
        database = args.database,
    })

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end

    self.conn = conn

    return self
end

function Client:query(sql)
    local res, err, errno, sqlstate = self.conn:query(sql)

    if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    end

    return res
end

function Client:keepalive()
    local ok, err = self.conn:set_keepalive()
    if not ok then
        ngx.say("failed to set keepalive: ", err)
        return
    end
end

return Client
