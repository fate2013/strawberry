local ActiveRecord = require "framework.db.mysql.active_record"
local mysql_config = require "test.config.mysql"

local Role = {
    table_name = "role",
    config_group = "default",
    config = mysql_config["default"],
}
Role.__index = Role 

setmetatable(Role, {
    __index = ActiveRecord,
})

function Role:users()
    local User = require "test.models.user"
    return self:belongs_to_many(User)
end

return Role
