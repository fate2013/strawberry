local Registry = require("framework.registry"):new("sys")

local Queue = {}

Queue.__index = Queue

function Queue:new(params)
    local DriverFactory = require "framework.queue.driver_factory"
    local driver = DriverFactory:factory(params['driver'], params['connection'], params['name'])
    return setmetatable({
        name = params['name'],
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
