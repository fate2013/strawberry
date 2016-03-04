local Query = require "framework.db.mysql.query"

local ActiveRecord = {
    group = "default",
}
ActiveRecord.__index = ActiveRecord
    
function ActiveRecord:new()
    return setmetatable({}, ActiveRecord)
end

function ActiveRecord:find()
    return Query:new(self)
end

return ActiveRecord
