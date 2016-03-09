local Query = require "framework.db.mysql.query"

local ActiveRecord = {
    table_name = "",
    config_group = "default",
    config = {},
}
ActiveRecord.__index = ActiveRecord
 
function ActiveRecord:new(row, from_db)
    if from_db == nil then from_db = false end
    if row == nil then row = {} end
    local model = {
        attributes = row,
        is_new = not from_db,
    }
    setmetatable(model, {
        __newindex = function(self, key, value)
            self.attributes[key] = value
        end,
        __index = self,
    })
    return model
end

function ActiveRecord:find()
    return Query:new(self)
end

local function insert(self)
    return Query:new(self):insert(self.table_name, self.attributes)
end

local function update(self)
    return Query:new(self):update(self.table_name, self.attributes, self.attributes.id)
end

function ActiveRecord:save()
    if self.is_new then
        return insert(self).affected_rows > 0
    else
        return update(self).affected_rows > 0
    end
end

function ActiveRecord:to_array()
    return self.attributes
end

return ActiveRecord
