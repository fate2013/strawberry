local init_by_lua = {}
function init_by_lua:run()
    local conf = require 'nginx.init.config'
    ngx.zhou = conf
end

return init_by_lua
