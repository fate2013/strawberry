local QueryBuilder = require "framework.db.mysql.query_builder"
local Utils = require "framework.libs.utils"

local Query = {
    is_query = true,
}
Query.__index = Query

function Query:new(model_class)
    return setmetatable({
        p_as_array = false,

        p_select = {},
        p_from = model_class.table_name,
        p_where = {},
        p_limit = nil,
        p_offset = nil,
        p_order_by = {},
        p_group_by = {},

        p_with = {},

        model_class = model_class,
        query_builder = QueryBuilder:new(),
        foreign_key = nil,
        local_key = nil,
        primary_model = nil,
        pivot = nil,

        multiple = false,
    }, Query)
end

function Query:as_array(p_as_array)
    if p_as_array == nil then
        p_as_array = true
    end
    self.p_as_array = p_as_array
    return self
end

function Query:select(columns)
    self.p_select = columns
    return self
end

function Query:from(table_name)
    self.p_from = table_name
    return self
end

function Query:where(column, value)
    Utils.tappend(self.p_where, column .. "='" .. value .. "'")
    return self
end

function Query:where_in(column, values)
    Utils.tappend(self.p_where, column .. " in ('" .. table.concat(values, "','") .. "')")
    return self
end

function Query:where_like(column, like)
    Utils.tappend(self.p_where, column .. " like '" .. like .. "'")
    return self
end

local function parse_multi_conditions(conditions)
    local comp = string.upper(conditions[1])
    table.remove(conditions, 1)
    local where_list = {}
    for _, condition in ipairs(conditions) do
        if type(condition) == "table" then
            Utils.tappend(where_list, parse_multi_conditions(condition))
        else
            Utils.tappend(where_list, condition)
        end
    end
    return "(" .. table.concat(where_list, " " .. comp .. " ") .. ")"
end

function Query:where_multi(conditions)
    Utils.tappend(self.p_where, parse_multi_conditions(conditions))
    return self
end

function Query:group_by(column)
    Utils.tappend(self.p_group_by, column)
    return self
end

--column: {'field', 'asc/desc'}
function Query:order_by(column, type)
    Utils.tappend(self.p_order_by, {column, type})
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

function Query:with(relation)
    Utils.tappend(self.p_with, relation)
    return self
end

local function normalize_relations(self, model)
    local with = self.p_with
    local p_as_array = self.p_as_array
    local relations = {}
    for _, name in ipairs(with) do
        local pos = string.find(name, "%.")
        local child_name = nil
        if pos then
            child_name = string.sub(name, pos + 1)
            name = string.sub(name, 0, pos - 1)
        end
        local relation = model:get_relation(name)
        if child_name then
            Utils.tappend(relation.p_with, child_name)
        end
        if p_as_array then
            relation:as_array()
        end
        relations[name] = relation
    end

    return relations
end

local function filter_by_models(self, foreign_key, local_key, primary_models)
    local keys = {}
    for _, primary_model in ipairs(primary_models) do
        Utils.tappend(keys, primary_model[local_key])
    end
    self:where_in(foreign_key, keys)
end

local function build_buckets(self, models, pivot_rows)
    local map = nil
    if pivot_rows then
        map = {}
        for _, row in pairs(pivot_rows) do
            local foreign_key = row[self.pivot.foreign_key]
            local other_key = row[self.pivot.other_key]
            if not map[other_key] then
                map[other_key] = {}
            end
            Utils.tappend(map[other_key], foreign_key)
        end
    end
    local buckets = {}
    if map then
        for _, model in ipairs(models) do
            local key = model[self.foreign_key]
            for _, foreign_key in pairs(map[key]) do
                if not buckets[foreign_key] then
                    buckets[foreign_key] = {}
                end
                Utils.tappend(buckets[foreign_key], model)
            end
        end
    else
        for _, model in ipairs(models) do
            local key = model[self.foreign_key]
            if not buckets[key] then
                buckets[key] = {}
            end
            Utils.tappend(buckets[key], model)
        end
    end
    return buckets
end

local function find_pivot_rows(self, primary_models)
    local query = Query:new(self.model_class)
    query.local_key = self.local_key
    filter_by_models(query, self.pivot.foreign_key, self.local_key, primary_models)
    return query:from(self.pivot.table):as_array():all()
end

local function populate_relation(self, name, primary_models)
    local pivot_rows = {}
    if self.pivot then
        pivot_rows = find_pivot_rows(self, primary_models)
        filter_by_models(self, self.foreign_key, self.pivot.other_key, pivot_rows)
    else
        filter_by_models(self, self.foreign_key, self.local_key, primary_models)
    end
    if not self.multiple and #primary_models == 1 then
        local model = self:one()
        local primary_model = primary_models[1]
        if self.p_as_array then
            primary_model[name] = model
        else
            primary_model:populate_relation(name, model)
        end
    else
        local models = {}
        if self.p_as_array then
            models = self:as_array():all()
        else
            models = self:all()
        end
        local buckets = {}
        if self.pivot then
            buckets = build_buckets(self, models, pivot_rows)
        else
            buckets = build_buckets(self, models)
        end
        for _, primary_model in ipairs(primary_models) do
            local records = buckets[primary_model[self.local_key]]
            if self.p_as_array then
                primary_model[name] = records
            else
                primary_model:populate_relation(name, records)
            end
        end
    end
end

local function find_with(self, primary_models)
    local model = self.model_class:new()
    local relations = normalize_relations(self, model)
    for name, relation in pairs(relations) do
        populate_relation(relation, name, primary_models)
    end
end

-- TODO index by feature
local function populate(self, rows)
    if not rows then
        return nil
    end
    if self.p_as_array then
        if #self.p_with > 0 then
            find_with(self, rows)
        end
        return rows
    end
    local models = {}
    for _, row in ipairs(rows) do
        Utils.tappend(models, self.model_class:new(row, true))
    end
    if #self.p_with > 0 then
        find_with(self, models)
    end
    return models
end

function Query:one()
    self.p_limit = 1
    local sql = self.query_builder:build(self)   
    local row = self.model_class:get_slave_conn():query_one(sql)
    return populate(self, {row})[1]
end

function Query:all()
    local sql = self.query_builder:build(self)
    local rows = self.model_class:get_slave_conn():query_all(sql)
    return populate(self, rows)
end

function Query:insert(table_name, columns)
    local sql = self.query_builder:insert(table_name, columns)
    return self.model_class:get_master_conn():execute(sql)
end

function Query:update(table_name, columns, primary_key)
    local sql = self.query_builder:update(table_name, columns, primary_key)
    return self.model_class:get_master_conn():execute(sql)
end

function Query:find_for(key)
    if self.pivot then
        local pivot_rows = find_pivot_rows(self, {self.primary_model})
        local keys = {}
        for _, row in ipairs(pivot_rows) do
            Utils.tappend(keys, row[self.pivot.other_key])
        end
        return self:where_in(self.foreign_key, keys):all()
    else
        self:where(self.foreign_key, self.primary_model[self.local_key])
        if self.multiple then
            return self:all()
        else
            return self:one()
        end
    end
end

return Query
