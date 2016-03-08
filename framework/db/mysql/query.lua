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
    return setmetatable({
        as_array = false,

        p_select = {},
        p_from = model_class.table_name,
        p_where = {},
        p_limit = nil,
        p_offset = nil,
        p_order_by = {},
        p_group_by = {},

        model_class = model_class,
        query_builder = QueryBuilder:new(),
        replica = Replica:instance(model_class.config_group, model_class.config),
    }, Query)
end

function Query:as_array(tobe)
    if tobe == nil then
        tobe = true
    end
    self.as_array = tobe
    return self
end

-- TODO auto schema and validate column
function Query:select(columns)
    self.p_select = columns
    return self
end

function Query:from(table)
    self.p_from = table
    return self
end

function Query:where(column, value)
    tappend(self.p_where, column .. "='" .. value .. "'")
    return self
end

function Query:where_in(column, values)
    tappend(self.p_where, column .. " in ('" .. table.concat(values, "','") .. "')")
    return self
end

function Query:where_like(column, like)
    tappend(self.p_where, column .. " like '" .. like .. "'")
    return self
end

local function parse_multi_conditions(conditions)
    local comp = string.upper(conditions[1])
    table.remove(conditions, 1)
    local where_list = {}
    for _, condition in ipairs(conditions) do
        if type(condition) == "table" then
            tappend(where_list, parse_multi_conditions(condition))
        else
            tappend(where_list, condition)
        end
    end
    return "(" .. table.concat(where_list, " " .. comp .. " ") .. ")"
end

function Query:where_multi(conditions)
    tappend(self.p_where, parse_multi_conditions(conditions))
    return self
end

function Query:group_by(column)
    tappend(self.p_group_by, column)
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
    local row = get_conn(self):query_one(sql)
    if self.as_array then
        return row
    end
    return self.model_class:new(row)
end

function Query:all()
    local sql = self.query_builder:build(self)
    print_r(sql)
    return get_conn(self):query_all(sql)
end

return Query
