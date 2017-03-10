local cjson = require('cjson').new()
local qalarm = require('framework.log.alarm'):new('Qalarm')

local IndexController = {}

function IndexController:index()
    local view = self:getView()
    local p = {}
    p['test1'] = 'Welcome ...'
    p['test2'] = 'Powered by Openresty'
    view:assign(p)
    return view:display()
end

function IndexController:test()
    local p = {}
    p['t'] = 'abc'
    p['s'] = 'def'
    qalarm:send('test', 'mysql', '200', 'test lua')
    return cjson.encode(p)
end

return IndexController
