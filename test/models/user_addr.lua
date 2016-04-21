local ActiveRecord = require "framework.db.mysql.active_record"
local mysql_config = require "test.config.mysql"

local UserAddr = {
    table_name = "user_addr",
    config_group = "default",
}
UserAddr.__index = UserAddr

setmetatable(UserAddr, {
    __index = ActiveRecord,
})

return UserAddr 
