local mysql = require "resty.mysql"

local Client = {
    clients = {},
}
Client.__index = Client

function Client:new()
    return setmetatable({
        conn = nil,
    }, Client)
end

function Client:connect(args)
    if self.conn then
        return self
    end

    if not args.timeout then args.timeout = 0 end
    if not args.port then args.port = 3306 end

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

    table.insert(Client.clients, self)

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
    end
end

return Client
