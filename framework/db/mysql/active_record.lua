local Query = require "framework.db.mysql.query"
local Schema = require "framework.db.mysql.schema"
local Replica = require "framework.db.mysql.replica"
local Registry = require("framework.registry"):new("sys")

local ActiveRecord = {
    table_name = "",
    primary_key = "id",
    config_group = "default",
    table_schema = nil,
    replica = nil,
}

ActiveRecord.__index = ActiveRecord

local function get_relation(query, key, base_model)
    if base_model.related[key] then
        return base_model.related[key]
    end
    local relation = query:find_for(key)
    base_model.related[key] = relation
    return relation
end

local function recursive_index(table, key, base_table)
    local value = rawget(base_table, "attributes")[key]
    if value then
        return value
    end
    local index = rawget(table, "__index")
    if index == table then
        return nil
    end
    if index then
        local getter = "get_" .. key
        local value = index[getter]
        if value then
            if type(value) == "function" then
                local res = value(base_table)
                if res.is_query then
                    return get_relation(res, key, base_table)
                else
                    return res
                end
            end
            return value
        end
        value = index[key]
        if value then
            return value
        elseif type(index) == "table" then
            return recursive_index(index, key, base_table)
        else
            return nil
        end
    end

    return nil
end

function ActiveRecord:new(row, from_db)
    if from_db == nil then from_db = false end
    if not row then row = {} end
    local model = {
        attributes = row,
        is_new = not from_db,
        updated_columns = {},
        related = {},
    }
    model.__index = self
    return setmetatable(model, {
        __newindex = function(table, key, value)
            if self:get_columns()[key] then
                rawset(table.updated_columns, key, value)
                rawset(table.attributes, key, value)
            else
                rawset(table, key, value)
            end
        end,
        __index = function(table, key)
            return recursive_index(table, key, table)
        end
    })
end

function ActiveRecord:get_key()
    return self[self.primary_key]
end

function ActiveRecord:get_replica()
    local replica = rawget(self, "replica")
    if replica then
        return replica
    end
    replica = Replica:instance(self.config_group, Registry.app.config.mysql[self.config_group])
    rawset(self, "replica", replica)
    return replica
end

function ActiveRecord:get_master_conn()
    return self:get_replica():master()
end

function ActiveRecord:get_slave_conn()
    local conn = self:get_replica():slave()
    if not conn then
        conn = self:get_master_conn()
    end
    return conn
end

function ActiveRecord:get_table_schema()
    local table_schema = rawget(self, "table_schema")
    if table_schema then
        return table_schema
    end

    table_schema = Schema:new(self)
    table_schema:load_table_schema()
    rawset(self, "table_schema", table_schema)
    return table_schema
end

function ActiveRecord:get_columns()
    local table_schema = self:get_table_schema()
    return table_schema.columns
end

function ActiveRecord:find()
    return Query:new(self)
end

local function insert(self)
    return Query:new(self):insert(self.table_name, self.attributes)
end

local function update(self)
    local attributes = {}
    for key, value in pairs(self.attributes) do
        if self.updated_columns[key] then
            attributes[key] = value
        end
    end
    return Query:new(self):update(self.table_name, attributes, self.attributes[self.primary_key])
end

function ActiveRecord:save()
    if self.is_new then
        local success = insert(self).affected_rows > 0
        if success then
            self.is_new = false
        end
        return success
    else
        -- TODO only update if new value not equals old value
        -- setted column value may not be dirty
        local success = update(self).affected_rows > 0
        if success then
            self.updated_columns = {}
        end
        return success
    end
end

function ActiveRecord:to_array()
    return self.attributes
end

-- Relations
function ActiveRecord:has_one(class, foreign_key)
    local query = class:find()
    if not foreign_key then
        foreign_key = self.table_name .. "_id"
    end
    query.local_key = self.primary_key
    query.foreign_key = foreign_key
    query.primary_model = self
    query.multiple = false
    return query
end

function ActiveRecord:has_many(class, foreign_key)
    local query = class:find()
    if not foreign_key then
        foreign_key = self.table_name .. "_id"
    end
    query.local_key = self.primary_key
    query.foreign_key = foreign_key
    query.primary_model = self
    query.multiple = true
    return query
end

function ActiveRecord:belongs_to(class, local_key)
    local query = class:find()
    if not local_key then
        local_key = class.table_name .. "_id"
    end
    query.local_key = local_key
    query.foreign_key = class.primary_key
    query.primary_model = self
    query.multiple = false
    return query
end

function ActiveRecord:belongs_to_many(class, pivot_table, foreign_key, other_key, local_key, other_local_key)
    local query = class:find()
    if not pivot_table then
        if self.table_name < class.table_name then
            pivot_table = self.table_name .. "_" .. class.table_name
        else
            pivot_table = class.table_name .. "_" .. self.table_name
        end
    end
    if not foreign_key then
        foreign_key = self.table_name .. "_id"
    end
    if not other_key then
        other_key = class.table_name .. "_id"
    end
    if not local_key then
        local_key = self.primary_key
    end
    if not other_local_key then
        other_local_key = class.primary_key
    end
    local pivot = {
        table = pivot_table,
        foreign_key = foreign_key,
        other_key = other_key,
    }
    query.primary_model = self
    query.local_key = local_key
    query.foreign_key = other_local_key
    query.pivot = pivot
    query.multiple = true
    return query
end

function ActiveRecord:get_relation(name)
    local getter = "get_" .. name
    if self[getter] then
        return self[getter](self)
    else
        return nil
    end
end

function ActiveRecord:populate_relation(name, records)
    self.related[name] = records
end

return ActiveRecord
