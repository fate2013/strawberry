local QueryBuilder = require "framework.db.mysql.query_builder"
local Connection = require "framework.db.mysql.connection"
local Replica = require "framework.db.mysql.replica"

local function tappend(t, v) t[#t+1] = v end

local Query = {}
Query.__index = Query

local function get_conn(query)
    return query.replica:master()
end

function Query:new(model_class)
    local table_name
    if model_class["table_name"] then
        table_name = model_class.table_name()
    end
    return setmetatable({
        p_select = {},
        p_from = table_name,
        p_where = {},
        p_limit = nil,
        p_offset = nil,
        p_order_by = {},

        model_class = model_class,
        query_builder = QueryBuilder:new(),
        replica = Replica:instance(model_class.group, model_class.config),
    }, Query)
end

-- TODO validate column
function Query:select(columns)
    self.p_select = columns
    return self
end

function Query:from(table)
    self.p_from = table
    return self
end

function Query:where(column, value)
    self.p_where[column] = value
    return self
end

--column: {'field', 'asc/desc'}
function Query:order_by(column)
    tappend(self.p_order_by, column)
    return self
end

function Query:limit(limit)
    self.p_limit = limit
    return self
end

function Query:offset(offset)
    self.p_offset = offset
    return self
end

function Query:one()
    self.p_limit = 1
    local sql = self.query_builder:build(self)   
    return get_conn(self):query_one(sql)
end

function Query:all()
    local sql = self.query_builder:build(self)
    return get_conn(self):query_all(sql)
end

return Query
