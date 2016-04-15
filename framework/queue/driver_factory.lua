local DriverFactory = {}

function DriverFactory:factory(driver_type, connection, name)
    if driver_type == "redis" then
        local redis_driver = require "framework.queue.driver.redis"
        return redis_driver:new(connection, name)
    end
end

return DriverFactory
