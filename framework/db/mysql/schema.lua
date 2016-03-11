local function tappend(t, v) t[#t+1] = v end

local Schema = {}
Schema.__index = Schema

function Schema:new(model_class)
    return setmetatable({
        model_class = model_class,
        columns = {},
    }, Schema)
end

local function load_columns(self)
    local sql = "SHOW FULL COLUMNS FROM " .. self.model_class.table_name
    local rows = self.model_class:get_slave_conn():query_all(sql)
    for _, row in ipairs(rows) do
        self.columns[row.Field] = 1
    end
end

-- TODO auto load primary key
function Schema:load_table_schema()
    load_columns(self)
end

return Schema
