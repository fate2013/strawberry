local Queue = {}

Queue.__index = Queue

function Queue:new(name, driver_type, connection)
    local DriverFactory = require "framework.queue.driver_factory"
    local driver = DriverFactory:factory(driver_type, connection, name)
    return setmetatable({
        name = name,
        driver = driver,
    }, Queue)
end

function Queue:push(element)
    self.driver:push(element)
end

function Queue:pop()
    return self.driver:pop()
end

return Queue
