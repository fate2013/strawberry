local ActiveRecord = require "framework.db.mysql.active_record"
local mysql_config = require "test.config.mysql"

local Profile = {
    table_name = "profile",
    config_group = "default",
    config = mysql_config["default"],
}
Profile.__index = Profile

setmetatable(Profile, {
    __index = ActiveRecord,
})

function Profile:get_user()
    local User = require "test.models.user"
    return self:belongs_to(User)
end

function Profile:get_user_addr()
    local UserAddr = require "test.models.user_addr"
    return self:has_one(UserAddr)
end

return Profile
