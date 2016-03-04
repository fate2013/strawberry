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
    end
    return "SELECT " .. table.concat(select, ",")
end

--TODO
local function build_from(table)
    return "FROM " .. table
end

local function build_where(condition)
    local where = {}
    for k, v in pairs(condition) do
        where = tappend(where, k .. "=" .. v)
    end
    local where_str = table.concat(where, " AND ")
    if #where > 0 then
        where_str = "WHERE " .. where_str
    end
    return where_str
end

local function build_limit(limit, offset)
    return "LIMIT " .. offset .. " " .. limit
end

function QueryBuilder:build(query)
    local clauses = {
        build_select(query.select),
        build_from(query.from),
        build_where(query.where),
        build_limit(query.limit, query.offset),
    }
    return table.concat(clauses, " ")
end

return QueryBuilder
