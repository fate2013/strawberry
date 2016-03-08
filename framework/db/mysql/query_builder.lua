local function tappend(t, v) t[#t+1] = v end

local QueryBuilder = {}
QueryBuilder.__index = QueryBuilder

function QueryBuilder:new()
    return setmetatable({}, QueryBuilder)
end

local function build_select(columns)
    local select = {}
    if #columns == 0 then
        tappend(select, "*")
    else 
        select = columns
    end
    return "SELECT " .. table.concat(select, ",")
end

--TODO multi tables
local function build_from(table)
    return "FROM " .. table
end

local function build_where(condition)
    local where = {}
    for k, v in pairs(condition) do
        tappend(where, k .. "='" .. v .. "'")
    end
    local where_str = ""
    if #where > 0 then
        where_str = "WHERE " .. table.concat(where, " AND ")
    end
    return where_str
end

local function build_order_by()
end

local function build_limit(limit, offset)
    if limit and offset then
        return "LIMIT " .. offset .. "," .. limit
    elseif limit then
        return "LIMIT " .. limit
    end
    return ""
end

function QueryBuilder:build(query)
    local clauses = {
        build_select(query.p_select),
        build_from(query.p_from),
        build_where(query.p_where),
        build_order_by(query.p_order_by),
        build_limit(query.p_limit, query.p_offset),
    }
    return table.concat(clauses, " ")
end

return QueryBuilder
