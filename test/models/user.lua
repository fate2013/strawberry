local ActiveRecord = require "framework.db.mysql.active_record"
local mysql_config = require "test.config.mysql"

local config_group = "default"

local User = {
    group = config_group,
    config = mysql_config[config_group],
}
User.__index = User

setmetatable(User, {
    __index = ActiveRecord, -- this is what makes the inheritance work
})

function User:new()
    print_r(mysql_config)
    return setmetatable({
    }, User)
end

function User.table_name()
    return "user"
end

return User
