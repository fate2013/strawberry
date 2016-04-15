local RedisDriver = {}

RedisDriver.__index = RedisDriver

function RedisDriver:new(connection, name)
    local obj = setmetatable({
        name = name,
        connection = connection,
    }, RedisDriver)

    return obj
end

function RedisDriver:push(element)
    self.connection:query("lpush", self.name, element)
end

function RedisDriver:pop()
    return self.connection:query("brpop", self.name, 0)[2]
end

return RedisDriver
