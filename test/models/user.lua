local ActiveRecord = require "framework.db.mysql.active_record"
local mysql_config = require "test.config.mysql"

local User = {
    table_name = "user",
    config_group = "default",
    config = mysql_config["default"],
}
User.__index = User

setmetatable(User, {
    __index = ActiveRecord,
})

return User
