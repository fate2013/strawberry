local DriverFactory = {}

function DriverFactory:factory(driver_type, connection_definition, name)
    if driver_type == "redis" then
        local RedisConnection = require "framework.db.redis.connection"
        local connection = RedisConnection:new(
            connection_definition['host'],
            connection_definition['port'],
            connection_definition['conn_timeout'],
            connection_definition['pool_size'],
            connection_definition['keepalive_time'],
            connection_definition['pwd']
        )
        local redis_driver = require "framework.queue.driver.redis"
        return redis_driver:new(connection, name)
    end
end

return DriverFactory
