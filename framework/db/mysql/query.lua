local QueryBuilder = require "framework.db.mysql.query_builder"
local Connection = require "framework.db.mysql.connection"
local Replica = require "framework.db.mysql.replica"

local Query = {}
Query.__index = Query

local function get_conn(query)
    return query.replica.master
end

function Query:new(model_class)
    local table_name
    if model_class["table_name"] then
        table_name = model_class:table_name()
    end
    return setmetatable({
        select = {},
        from = table_name,
        where = {},
        limit = nil,
        offset = nil,
        order_by = {},

        model_class = model_class,
        query_builder = QueryBuilder:new(),
        replica = Replica:instance(model_class.group, model_class.config),
    }, Query)
end

function Query:where(column, value)
    self.where[column] = value
    return self
end

function Query:one()
    self.limit = 1
    local sql = self.query_builder:build(self)   
    return get_conn():query_one(sql)
end

return Query
