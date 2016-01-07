local cjson = require('cjson').new()

local IndexController = {}

function IndexController:index()
    local view = self:getView()
    local p = {}
    p['vanilla'] = 'Welcome To Vanilla...'
    p['zhoujing'] = 'Power by Openresty'
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
