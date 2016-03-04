local ActiveRecord = require "framework.db.mysql.active_record"
local mysql_config = require "test.config.mysql"

local User = {}
User.__index = User

setmetatable(User, {
    __index = ActiveRecord, -- this is what makes the inheritance work
})

function User:new()
    print_r(mysql_config.default)
    return setmetatable({
        group = "default",
        --TODO
        config = mysql_config.default,
    }, User)
end

function User:table_name()
    return "user"
end

return User
