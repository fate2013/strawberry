local cjson = require "cjson.safe"

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
    return cjson.encode(p)
end

return IndexController
