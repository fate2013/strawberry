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

function Profile:user()
    local User = require "test.models.user"
    return self:belongs_to(User)
end

return Profile
