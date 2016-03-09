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
    local where_str = ""
    if #condition > 0 then
        where_str = "WHERE " .. table.concat(condition, " AND ")
    end
    return where_str
end

local function build_group_by(columns)
    if #columns == 0 then
        return ""
    end
    return "GROUP BY " .. table.concat(columns, ",")
end

local function build_order_by(columns)
    if #columns == 0 then
        return ""
    end
    local order_by = {}
    if #columns > 0 then
        for k, column in ipairs(columns) do
            local order_str = table.concat(column, " ")
            tappend(order_by, order_str)
        end
    end
    return "ORDER BY " .. table.concat(order_by, ",")
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
        build_group_by(query.p_group_by),
        build_order_by(query.p_order_by),
        build_limit(query.p_limit, query.p_offset),
    }
    local non_empty_clauses = {}
    for k, clause in ipairs(clauses) do
        if clause ~= "" then
            tappend(non_empty_clauses, clause)
        end
    end
    return table.concat(non_empty_clauses, " ")
end

function QueryBuilder:insert(table_name, columns)
    local keys = {}
    local values = {}
    for k, v in pairs(columns) do
        tappend(keys, k)
        tappend(values, v)
    end
    local sql = "INSERT INTO " .. table_name ..
        "(" .. table.concat(keys, ",") .. ")" ..
        " VALUES('" .. table.concat(values, "','") .. "')"
    return sql
end

function QueryBuilder:update(table_name, columns, primary_key)
    local set_clause = "SET "
    local sets = {}
    for k, v in pairs(columns) do
        tappend(sets, k .. "='" .. v .. "'")
    end
    local sql = "UPDATE " .. table_name ..
        " SET " .. table.concat(sets, ",") ..
        " WHERE id=" .. primary_key
    return sql
end

return QueryBuilder
