local ActiveRecord = require "framework.db.mysql.active_record"
local mysql_config = require "test.config.mysql"

local User = {
    table_name = "user",
    config_group = "default",
}
User.__index = User

setmetatable(User, {
    __index = ActiveRecord,
})

function User:get_profile()
    local Profile = require "test.models.profile"
    return self:has_one(Profile)
end

function User:get_orders()
    local Order = require "test.models.order"
    return self:has_many(Order)
end

function User:get_roles()
    local Role = require "test.models.role"
    return self:belongs_to_many(Role)
end

return User
