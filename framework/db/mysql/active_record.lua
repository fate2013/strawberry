local Query = require "framework.db.mysql.query"

local ActiveRecord = {
    table_name = "",
    config_group = "default",
    config = {},
}
ActiveRecord.__index = ActiveRecord
    
function ActiveRecord:new(row)
    return setmetatable({
        attributes = row,
    }, self)
end

function ActiveRecord:find()
    return Query:new(self)
end

function ActiveRecord:to_array()
    return self.attributes
end

return ActiveRecord
