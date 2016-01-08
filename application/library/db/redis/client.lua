local redis = require "resty.redis"

local Client = {
}
Client.__index = Client

function Client:new()
    return setmetatable({
        conn = nil
    }, Client)
end

function Client:connect(args)
    if self.conn then
        return self
    end

    if not args.timeout then args.timeout = 0 end
    if not args.port then args.port = 6379 end

    local conn = redis:new()

    conn:set_timeout(args.timeout)

    local ok, err = conn:connect(args.host, args.port)
    if not ok then
        ngx.say("failed to connect: ", err)
        return
    end


    self.conn = conn

    return self
end

function Client:query(cmd, ...)
    local res, err = self.conn[cmd](self.conn, ...)
    if not res or res == ngx.null then
        return
    end

    return res
end

function Client:keepalive()
    -- put it into the connection pool of size 100,
    -- with 10 seconds max idle time
    local ok, err = self.conn:set_keepalive(10000, 100)
    if not ok then
        ngx.say("failed to set keepalive: ", err)
    end
end

return Client
